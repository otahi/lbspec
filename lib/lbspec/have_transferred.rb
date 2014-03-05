require 'net/ssh/multi'
require 'rspec/expectations'

RSpec::Matchers.define :have_transferred do |vhost|
  @ssh = {}
  @threads = []

  match do |nodes|
    @keyword = gen_keyword
    connect_nodes nodes
    send_request vhost, 80
    sleep 5
    disconnect_nodes
    is_ok?
  end

  def gen_keyword
    t = Time.now
    t.to_i.to_s + t.nsec.to_s
  end

  def connect_nodes(nodes)
    if nodes.respond_to? :each
      nodes.each { |node| connect_node(node) }
    else
      connect_node(nodes)
    end
  end

  def connect_node(node)
    @threads << Thread.new {
      @ssh[node.to_sym] = Net::SSH.start(node, 'otahi', :config => true)
      channel = @ssh[node.to_sym].open_channel do |ch|
        channel.request_pty do |ch, success|
          raise "Could not obtain pty " if !success
          channel.exec "sudo ngrep #{@keyword}" do |ch, stream, data|
            ch.on_data do |c, data|
              Thread.current[:outdata] ||= ''
              Thread.current[:outdata] += data
            end
          end
        end
      end
      ssh.loop
    }
  end

  def disconnect_nodes
    @ssh.each do |node, ssh|
      ssh.close if ! ssh.closed?
    end
  end

  def send_request(vhost, port)
    system("echo #{@keyword} | nc #{vhost} #{port}")
  end
  def is_ok?
    @threads.each do |t|
      if /#{@keyword}/ === t[:outdata]
        break true
      else
        false
      end
    end
  end
end
