require 'net/ssh'
require 'rspec/expectations'

RSpec::Matchers.define :have_transferred do |nodes|
  @ssh = {}
  @threads = []

  match do |vhost|
    @keyword = gen_keyword
    connect_nodes nodes
    send_request(vhost, 80)
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
      @ssh[node.to_sym] = Net::SSH.start(node, nil, :config => true)
      @ssh[node.to_sym].open_channel do |ch|
        ch.request_pty do |ch, success|
          raise "Could not obtain pty " if !success
          ch.exec "sudo ngrep #{@keyword}" do |ch, stream, data|
            ch.on_data do |c, data|
              if /#{@keyword}/ === data
                @results.push(true)
              end
            end
          end
        end
      end
    }
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
    @threads.each do |t|
      if /#{@keyword}/ === t[:outdata]
        break true
      else
        false
      end
    end
  end
end
