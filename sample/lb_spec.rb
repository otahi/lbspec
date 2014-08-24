require_relative 'spec_helper'
require 'net/ssh'

describe 'sample spec' do
  before(:each) do
    key = Lbspec::Util.create_prove
    include_str = 'X-Test: 1  /test/healthcheck'
    Lbspec::Util.stub(:create_prove).and_return(key)
    channel_connected = double('channel_connected')
    channel_connected.stub(:request_pty).and_yield(channel_connected, true)
    channel_connected.stub(:exec).and_yield(channel_connected, nil, nil)
    channel_connected.stub(:on_data)
      .and_yield(nil, key + include_str)
      .and_yield(nil, key + include_str)
    ssh_connected = double('ssh_connected')
    ssh_connected.stub(:open_channel).and_yield(channel_connected)
    ssh_connected.stub(:closed?).and_return(false)
    ssh_connected.stub(:close)
    ssh_connected.stub(:exec!).and_return(true)
    Net::SSH.stub(:start).and_yield(ssh_connected).and_return(ssh_connected)
    Lbspec::Util.stub(:`).and_return(key + include_str) # `
    Lbspec::Util.stub(:exec_command).and_return '200 OK 404'
    Kernel.stub(:system).and_return true
    Kernel.stub(:`).and_return(include_str) # `
  end

  require_relative 'spec_helper'

  describe 'vhost_a' do
    it { should transfer('node_a') }
    it { should respond('200 OK') }
  end

  describe 'vhost_b' do
    it { should transfer(%w(node_b node_c)) }
    it { should respond('200 OK') }
  end

  describe 'vhost_c:80' do
    it { should transfer(%w(node_b node_c)).port(80) }
    it { should respond('404') }
  end

  describe 'vhost_c:80' do
    it { should transfer(%w(node_b node_c)).port(53).udp }
  end

  describe 'vhost_c:80/test/' do
    it { should transfer('node_c').http }
    it { should respond('200 OK').http }
  end

  describe 'vhost_c:443' do
    it { should transfer(%w(node_b node_c)).port(80).https.path('/test/') }
    it { should respond('200 OK').https.path('/test/') }
  end

  describe 'vhost_c:443/test/' do
    it do
      should transfer(%w(node_b node_c)).port(80).https
        .options(ignore_valid_ssl: true)
    end
    it do should respond('200 OK').path('/test/').https
        .options(ignore_valid_ssl: true)
    end
  end

  describe 'vhost_c:80/test/' do
    it { should transfer('node_c').http.from('node_a') }
  end

  describe 'loadbalancer' do
    it do should healthcheck('node_c')
        .include('/test/healthcheck').from('192.168.1.1')
    end
  end

  describe 'loadbalancer' do
    it { should healthcheck('node_c').include('/test/healthcheck').interval(5) }
  end
end
