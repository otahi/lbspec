# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'net/ssh'

describe '#transfer' do
  before(:each) do
    key = Lbspec::Util.create_prove
    include_str = 'X-Test: 1'
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
    Kernel.stub(:system).and_return true
    Kernel.stub(:`).and_return(key + include_str) # `
  end

  it 'should test transfer a node' do
    'vhost_a'.should transfer('node_a')
  end
  it 'should test transfer nodes' do
    'vhost_a'.should transfer(%w(node_a node_b))
  end
  it 'should test transfer a node on port 80' do
    'vhost_a'.should transfer('node_a').port(80)
  end
  it 'should test transfer vhost:80 and a node on port 80' do
    'vhost_a:80'.should transfer('node_a').port(80)
  end
  it 'should test transfer vhost:80 and a node on port 80/tcp' do
    'vhost_a:80'.should transfer('node_a').port(80).tcp
  end
  it 'should test transfer vhost:80 and a node on port 53/tcp' do
    'vhost_a:80'.should transfer('node_a').port(53).udp
  end
  it 'should test transfer vhost:80 and a node with http' do
    'vhost_a:80'.should transfer('node_a').http
  end
  it 'should test transfer vhost:443 and a node with https' do
    'vhost_a:443'.should transfer('node_a').port(80).https
  end
  it 'should test transfer vhost:443 and a node:80 with https' do
    'vhost_a:443'.should transfer('node_a').port(80).https
  end
  it 'should test transfer vhost:443 and a node with https /test' do
    'vhost_a:443/test'.should transfer('node_a').https
  end
  it 'should test transfer vhost:443 with options for requests' do
    'vhost_a:443'.should transfer('node_a').https.path('/test')
      .options(ignore_valid_ssl: true)
    'vhost_a:443/test'.should transfer('node_a').https
      .options(ignore_valid_ssl: false, timeout: 5)
  end
  it 'should test transfer vhost:443 requests from specified host' do
    'vhost_a:443/test'.should transfer('node_a')
      .https.from('node_a')
  end
  it 'should test transfer vhost:80 and a node with http includes ' do
    'vhost_a:80'.should transfer('node_a').http
      .include('X-Test: 1')
    'vhost_a:80'.should transfer('node_a').http
      .include(/Test:/)
  end

  describe 'request_command' do
    it 'should create single header options for http' do
      Lbspec::Util.should_receive(:exec_command)
        .with(/ -H.*/, nil)
      Lbspec::Util.should_not_receive(:exec_command)
        .with(/ -H.* -H/, nil)
      'vhost_a:443'.should transfer('node_a').http
        .options(header: 'X-Test1:1')
    end
    it 'should create single header options for https' do
      Lbspec::Util.should_receive(:exec_command)
        .with(/ -H.*/, nil)
      Lbspec::Util.should_not_receive(:exec_command)
        .with(/ -H.* -H/, nil)
      'vhost_a:443'.should transfer('node_a').https
        .options(header: 'X-Test1:1')
    end
    it 'should create multi header options for http' do
      Lbspec::Util.should_receive(:exec_command)
        .with(/ -H.* -H/, nil)
      'vhost_a:443'.should transfer('node_a').http
        .options(header: %w(X-Test1:1 X-Test2:2))
    end
    it 'should create multi header options for https' do
      Lbspec::Util.should_receive(:exec_command)
        .with(/ -H.* -H/, nil)
      'vhost_a:443'.should transfer('node_a').https
        .options(header: %w(X-Test1:1 X-Test2:2))
    end
  end

end
