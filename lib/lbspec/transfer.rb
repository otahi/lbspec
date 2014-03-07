require 'net/ssh'
require 'rspec/expectations'

RSpec::Matchers.define :transfer do |nodes|
  @ssh = {}
  @threads = []
  @result = false

  match do |vhost|
    @keyword = gen_keyword
    connect_nodes nodes
    sleep 5
    send_request(vhost, 80)
    disconnect_nodes
    is_ok?
  end

  def gen_keyword
    t = Time.now
    t.to_i.to_s + t.nsec.to_s
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
    @ssh[node.to_sym] = Net::SSH.start(node, nil, :config => true) do |ssh|
      ssh.open_channel do |ch|
        ch.request_pty do |ch, success|
          raise "Could not obtain pty " if !success
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
    @ssh.each do |node, ssh|
      ssh.close if ! ssh.closed?
    end
  end

  def send_request(vhost, port)
    system("echo #{@keyword} | nc #{vhost} #{port}")
  end
  def is_ok?
    @result
  end
end
