require 'net/ssh'
require 'rspec/expectations'

RSpec::Matchers.define :transfer do |nodes|
  @ssh = []
  @threads = []
  @nodes_connected = []
  @result = false

  match do |vhost|
    gen_keyword
    connect_nodes nodes
    wait_nodes_connected nodes
    send_request(vhost, 80)
    disconnect_nodes
    is_ok?
  end

  def gen_keyword
    t = Time.now
    @keyword = t.to_i.to_s + t.nsec.to_s
  end

  def wait_nodes_connected(nodes)
    nodes_length = 1
    nodes_length = nodes.length if nodes.respond_to? :each

    until (@nodes_connected.length == nodes_length) do
      sleep 0.5
    end
  end

  def connect_nodes(nodes)
    if nodes.respond_to? :each
      nodes.each do |node|
        @threads << Thread.new { connect_node(node) }
      end
    else
      @threads << Thread.new { connect_node(nodes) }
    end
  end

  def connect_node(node)
    @ssh.push = Net::SSH.start(node, nil, :config => true) do |ssh|
      ssh.open_channel do |ch|
        ch.request_pty do |ch, success|
          raise "Could not obtain pty " if !success
          @nodes_connected.push(true)
          ch.exec "sudo ngrep #{@keyword}" do |ch, stream, data|
            ch.on_data do |c, data|
              @result = true if /#{@keyword}/ === data
            end
          end
        end
      end
    end
  end

  def disconnect_nodes
    @threads.each do |t|
      t.kill
    end
    @ssh.each do |ssh|
      ssh.close if ! ssh.closed?
    end
  end

  def send_request(vhost, port)
    system("echo #{@keyword} | nc #{vhost} #{port}")
  end
  def is_ok?
    @result
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
