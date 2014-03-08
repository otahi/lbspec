# -*- encoding: utf-8 -*-
require 'net/ssh'
require 'rspec/expectations'
require 'lbspec'

RSpec::Matchers.define :transfer do |nodes|
  @ssh = []
  @threads = []
  @nodes_connected = []
  @vhost_port = 80
  @node_port = 0
  @result = false
  Thread.abort_on_exception = true

  match do |vhost|
    @keyword = gen_keyword
    capture_on_nodes nodes
    wait_nodes_connected nodes
    send_request vhost
    disconnect_nodes
    @result
  end

  chain :port do |port|
    @node_port = port
  end

  def gen_keyword
    Lbspec::Util.gen_keyword
  end

  def wait_nodes_connected(nodes)
    nodes_length = (nodes.respond_to? :each) ? nodes.length : 1
    sleep 0.5 until @nodes_connected.length == nodes_length
  end

  def capture_on_nodes(nodes)
    if nodes.respond_to? :each
      nodes.each { |node| capture_on_node(node) }
    else
      capture_on_node(nodes)
    end
  end

  def capture_on_node(node)
    @threads << Thread.new do
      Net::SSH.start(node, nil, :config => true) do |ssh|
        @ssh << ssh
        ssh.open_channel { |channel| run_check channel }
      end
    end
  end

  def run_check(channel)
    channel.request_pty do |chan, success|
      fail 'Could not obtain pty' unless success
      @nodes_connected.push(true)
      exec_capture(chan, capture_cmd)
    end
  end

  def exec_capture(channel, command)
    channel.exec capture_cmd do |ch, stream, data|
      num_match = 0
      ch.on_data do |c, d|
        num_match += 1 if /#{@keyword}/ =~ d
        @result = true if num_match > 0
      end
    end
  end

  def capture_cmd
    port_str = @node_port > 0 ? "port #{@node_port}" : ''
    "sudo ngrep #{@keyword} #{port_str} | grep -v \"match:\""
  end

  def disconnect_nodes
    sleep 1
    @threads.each do |t|
      t.kill
    end
    @ssh.each do |ssh|
      ssh.close unless ssh.closed?
    end
  end

  def send_request(vhost)
    addr_port = Lbspec::Util.split_addr_port(vhost.to_s)
    vhost_addr, vhost_port = addr_port[:addr], addr_port[:port]
    @vhost_port = vhost_port if vhost_port > 0
    system("echo #{@keyword} | nc #{vhost_addr} #{@vhost_port}")
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
