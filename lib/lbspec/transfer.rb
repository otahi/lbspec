# -*- encoding: utf-8 -*-
require 'net/ssh'
require 'rspec/core'
require 'rspec/expectations'
require 'lbspec'

RSpec.configure do |c|
  c.add_setting :lbspec_capture_command      , default: nil
  c.add_setting :lbspec_udp_request_command  , default: nil
  c.add_setting :lbspec_tcp_request_command  , default: nil
  c.add_setting :lbspec_http_request_command , default: nil
  c.add_setting :lbspec_https_request_command, default: nil
end

RSpec::Matchers.define :transfer do |nodes|
  @ssh = []
  @threads = []
  @nodes_connected = []
  @chain_str = ''
  @protocol = nil
  @application = nil
  @http_path = '/'
  @vhost_port = 80
  @node_port = 0
  @options = {}

  @capture_command = lambda do |port, prove|
    port_str = port > 0 ? "port #{port}" : ''
    "sudo ngrep #{prove} #{port_str} | grep -v \"match:\""
  end

  @udp_request_command = lambda do |addr, port, prove|
    system("echo #{prove} | nc -u #{addr} #{port}")
  end
  @tcp_request_command = lambda do |addr, port, prove|
    system("echo #{prove} | nc #{addr} #{port}")
  end
  @http_request_command = lambda do |addr, port, path, prove|
    opt =  @options[:timeout] ? " -m #{@options[:timeout]}" : ''
    uri = 'http://' + "#{addr}:#{port}#{path}?#{prove}"
    system("curl -o /dev/null -s #{opt} #{uri}")
  end
  @https_request_command = lambda do |addr, port, path, prove|
    opt =  @options[:timeout] ? " -m #{@options[:timeout]}" : ''
    opt << (@options[:ignore_valid_ssl] ? ' -k' : '')
    uri = 'https://' + "#{addr}:#{port}#{path}?#{prove}"
    system("curl -o /dev/null -sk #{opt} #{uri}")
  end

  @result = false
  Thread.abort_on_exception = true

  match do |vhost|
    @prove = Lbspec::Util.create_prove
    override_commands
    capture_on_nodes nodes
    wait_nodes_connected nodes
    send_request vhost
    disconnect_nodes
    @result
  end

  chain :port do |port|
    @node_port = port
    @chain_str << " port #{port}"
  end

  chain :tcp do
    @protocol = :tcp
    @chain_str << ' tcp'
  end

  chain :udp do
    @protocol = :udp
    @chain_str << ' udp'
  end

  chain :http do
    @protocol = :tcp
    @application = :http
    @chain_str << ' http'
  end

  chain :https do
    @protocol = :tcp
    @application = :https
    @chain_str << ' https'
  end

  chain :path do |path|
    @http_path = path
    @chain_str << " via #{path}"
  end

  chain :options do |options|
    @options = options
  end

  def override_commands
    capture = RSpec.configuration.lbspec_capture_command
    udp_request = RSpec.configuration.lbspec_udp_request_command
    tcp_request = RSpec.configuration.lbspec_tcp_request_command
    http_request = RSpec.configuration.lbspec_http_request_command
    https_request = RSpec.configuration.lbspec_https_request_command
    @capture_command = capture if capture
    @udp_request_command = udp_request if udp_request
    @tcp_request_command = tcp_request if tcp_request
    @http_request_command = http_request if http_request
    @https_request_command = https_request if https_request
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
      Net::SSH.start(node, nil, config: true) do |ssh|
        @ssh << ssh
        ssh.open_channel { |channel| run_check channel }
      end
    end
  end

  def run_check(channel)
    channel.request_pty do |chan, success|
      fail 'Could not obtain pty' unless success
      @nodes_connected.push(true)
      exec_capture(chan)
    end
  end

  def exec_capture(channel)
    command = capture_command(@node_port, @prove)
    channel.exec command do |ch, stream, data|
      num_match = 0
      ch.on_data do |c, d|
        num_match += 1 if /#{@prove}/ =~ d
        @result = true if num_match > 0
      end
    end
  end

  def capture_command(port, prove)
    @capture_command[port, prove]
  end

  def disconnect_nodes
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
    if @application
      send_request_application(vhost_addr, @vhost_port, @prove)
    else
      send_request_transport(vhost_addr, @vhost_port, @prove)
    end
  end

  def send_request_application(addr, port, prove)
    case @application
    when :http
      @http_request_command[addr, port, @http_path, prove]
    when :https
      @https_request_command[addr, port, @http_path, prove]
    end
  end

  def send_request_transport(addr, port, prove)
    case @protocol
    when :udp
      @udp_request_command[addr, port, prove]
    else
      @tcp_request_command[addr, port, prove]
    end
  end

  description do
    "transfer requests to #{nodes}#{@chain_str}."
  end

  failure_message_for_should do |vhost|
    result =  "expected #{vhost} to transfer requests to"
    result << nodes.to_s
    result << @chain_str
    result << ', but did not.'
  end

  failure_message_for_should_not do |vhost|
    result =  "expected #{vhost} not to transfer requests to"
    result << nodes.to_s
    result << @chain_str
    result << ', but did.'
  end
end
