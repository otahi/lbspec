# -*- encoding: utf-8 -*-
require 'net/ssh'
require 'rspec/expectations'
require 'lbspec'

RSpec::Matchers.define :transfer do |nodes|
  @ssh = []
  @threads = []
  @nodes_connected = []
  @result = false
  Thread.abort_on_exception = true

  match do |vhost|
    @keyword = gen_keyword
    connect_nodes nodes
    wait_nodes_connected nodes
    send_request(vhost, 80)
    disconnect_nodes
    @result
  end

  def gen_keyword
    Lbspec::Util.gen_keyword
  end

  def wait_nodes_connected(nodes)
    nodes_length = 1
    nodes_length = nodes.length if nodes.respond_to? :each

    sleep 0.5 until @nodes_connected.length == nodes_length
  end

  def connect_nodes(nodes)
    if nodes.respond_to? :each
      nodes.each { |node| connect_node(node) }
    else
      connect_node(nodes)
    end
  end

  def connect_node(node)
    @threads << Thread.new do
      Net::SSH.start(node, nil, :config => true) do |ssh|
        ssh.open_channel do |channel|
          run_check channel
        end
      end
    end
  end

  def run_check(channel)
    channel.request_pty do |chan, success|
      fail 'Could not obtain pty' unless success
      @nodes_connected.push(true)
      chan.exec "sudo ngrep #{@keyword}" do |ch, stream, data|
        ch.on_data do |c, d|
          @result = true if /#{@keyword}/ =~ d
        end
      end
    end
  end

  def disconnect_nodes
    @threads.each do |t|
      t.kill
    end
    @ssh.each do |ssh|
      ssh.close unless ssh.closed?
    end
  end

  def send_request(vhost, port)
    system("echo #{@keyword} | nc #{vhost} #{port}")
  end

  description do
    "transfer requests to #{nodes}."
  end

  failure_message_for_should do |vhost|
    "expected #{vhost} to transfer requests to #{nodes}, but did not."
  end

  failure_message_for_should_not do |vhost|
    "expected #{vhost} not to transfer requests to #{nodes}, but it did."
  end
end
