# -*- encoding: utf-8 -*-
require 'lbspec'

# Lbspec is an RSpec plugin for easy Loadbalancer testing.
module Lbspec
  # Lbspec::Capture reqresent of capture
  class Capture
    Thread.abort_on_exception = true

    attr_reader :result, :output

    def initialize(nodes, port, prove, include_str = nil)
      @nodes = nodes.respond_to?(:each) ? nodes : [nodes]
      @port = port ? port : 0
      @prove = prove
      @include_str = include_str
      @threads = []
      @ssh = []
      @nodes_connected = []
      @result = false
      @output = []
      Util.log.debug("#{self.class} initialized #{inspect}")
    end

    def open
      @nodes.each do |node|
        open_node(node)
      end
      wait_connected
    end

    def close
      @threads.each do |t|
        t.kill
      end
      @ssh.each do |ssh|
        ssh.close unless ssh.closed?
      end
    end

    private

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
      channel.exec command do |ch, stream, data|
        ch.on_data do |c, d|
          whole_data << d
          patterns = [@prove]
          patterns << @include_str if @include_str
          @result = match_all?(whole_data, patterns)
        end
      end
      whole_data
    end

    def match_all?(string, patterns)
      num_patterns, num_match = 0, 0
      patterns.each do |pat|
        num_patterns += 1
        num_match += 1 if string.match(pat)
      end
      num_match == num_patterns
    end

    def capture_command
      port_str = @port > 0 ? "port #{@port}" : ''
      "sudo ngrep -W byline #{@prove} #{port_str} | grep -v \"match:\""
    end
  end
end
