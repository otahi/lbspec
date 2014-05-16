# -*- encoding: utf-8 -*-
require 'lbspec'

# Lbspec is an RSpec plugin for easy Loadbalancer testing.
module Lbspec
  # Lbspec::Capture reqresent of capture
  class Capture
    Thread.abort_on_exception = true

    attr_reader :result, :output

    def initialize(nodes, bpf = nil, prove = nil, include_str = nil,
                   term_sec = nil)
      @nodes = nodes.respond_to?(:each) ? nodes : [nodes]
      @bpf = bpf ? bpf : ''
      @prove = prove ? prove : ''
      @include_str = include_str
      @term_sec = term_sec ? term_sec : 5
      set_initial_value
      Util.log.debug("#{self.class} initialized #{inspect}")
    end

    def open
      @nodes.each { |node| open_node(node) }
      wait_connected
    end

    def close
      sleep 0.5 until capture_done?
      @threads.each do |t|
        t.kill
      end
      @ssh.each do |ssh|
        ssh.close unless ssh.closed?
      end
    end

    def self.bpf(options = {})
      is_first = true
      filter = ''

      options.each do |k, v|
        if k && v
          filter << ' and ' unless is_first
          filter << k.to_s.gsub('_', ' ') + ' ' + v.to_s
          is_first = false
        end
      end
      filter
    end

    private

    def set_initial_value
      @threads, @ssh, @nodes_connected = [], [], []
      @result = false
      @output = []
    end

    def open_node(node)
      @threads << Thread.new do
        Net::SSH.start(node, nil, config: true) do |ssh|
          @ssh << ssh
          ssh.open_channel do |channel|
            output = run_check channel
            @output.push(node: node, output: output)
          end
        end
      end
    end

    def wait_connected
      sleep 0.5 until @nodes_connected.length == @nodes.length
    end

    def run_check(channel)
      output = ''
      channel.request_pty do |chan, success|
        fail 'Could not obtain pty' unless success
        @nodes_connected.push(true)
        output = exec_capture(chan)
      end
      output
    end

    def exec_capture(channel)
      output = exec_capture_command(channel, capture_command)
      capture_command + "\n" +  output.to_s
    end

    def exec_capture_command(channel, command)
      whole_data = ''
      @start_sec = Time.now.to_i + 1
      channel.exec command do |ch, _stream , _data|
        ch.on_data do |_c, d|
          whole_data << d
          @result = match_all?(whole_data)
        end
        break if capture_done?
      end
      whole_data
    end

    def capture_done?
      now_sec = Time.now.to_i
      (@term_sec > 0 && now_sec - @start_sec > @term_sec) ? true : @result
    end

    def match_all?(string)
      patterns = [@prove]
      patterns << @include_str if @include_str
      num_patterns, num_match = 0, 0
      patterns.each do |pat|
        num_patterns += 1
        num_match += 1 if string.match(pat)
      end
      num_match == num_patterns
    end

    def capture_command
      "sudo ngrep -W byline #{@prove} #{@bpf} | grep -v \"match:\""
    end
  end
end
