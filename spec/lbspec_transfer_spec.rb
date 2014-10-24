# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'net/ssh'

describe '#transfer' do
  before(:each) do
    key = Lbspec::Util.create_prove
    include_str = 'X-Test: 1'
    allow(Lbspec::Util).to receive(:create_prove).and_return(key)
    channel_connected = double('channel_connected')
    allow(channel_connected).to receive(:request_pty)
      .and_yield(channel_connected, true)
    allow(channel_connected).to receive(:exec)
      .and_yield(channel_connected, nil, nil)
    allow(channel_connected).to receive(:on_data)
      .and_yield(nil, key + include_str)
      .and_yield(nil, key + include_str)
    ssh_connected = double('ssh_connected')
    allow(ssh_connected).to receive(:open_channel).and_yield(channel_connected)
    allow(ssh_connected).to receive(:closed?).and_return(false)
    allow(ssh_connected).to receive(:close)
    allow(ssh_connected).to receive(:exec!).and_return(true)
    allow(Net::SSH).to receive(:start)
      .and_yield(ssh_connected).and_return(ssh_connected)
    allow(Lbspec::Util).to receive(:`).and_return(key + include_str) # `
  end

  it 'should test transfer a node' do
    expect('vhost_a').to transfer('node_a')
  end
  it 'should test transfer nodes' do
    expect('vhost_a').to transfer(%w(node_a node_b))
  end
  it 'should test transfer a node on port 80' do
    expect('vhost_a').to transfer('node_a').port(80)
  end
  it 'should test transfer vhost:80 and a node on port 80' do
    expect('vhost_a:80').to transfer('node_a').port(80)
  end
  it 'should test transfer vhost:80 and a node on port 80/tcp' do
    expect('vhost_a:80').to transfer('node_a').port(80).tcp
  end
  it 'should test transfer vhost:80 and a node on port 53/tcp' do
    expect('vhost_a:80').to transfer('node_a').port(53).udp
  end
  it 'should test transfer vhost:80 and a node with http' do
    expect('vhost_a:80').to transfer('node_a').http
  end
  it 'should test transfer vhost:443 and a node with https' do
    expect('vhost_a:443').to transfer('node_a').port(80).https
  end
  it 'should test transfer vhost:443 and a node:80 with https' do
    expect('vhost_a:443').to transfer('node_a').port(80).https
  end
  it 'should test transfer vhost:443 and a node with https /test' do
    expect('vhost_a:443/test').to transfer('node_a').https
  end
  it 'should test transfer vhost:443 with options for requests' do
    expect('vhost_a:443').to transfer('node_a').https.path('/test')
      .options(ignore_valid_ssl: true)
    expect('vhost_a:443/test').to transfer('node_a').https
      .options(ignore_valid_ssl: false, timeout: 5)
  end
  it 'should test transfer vhost:443 requests from specified host' do
    expect('vhost_a:443/test').to transfer('node_a')
      .https.from('node_a')
  end
  it 'should test transfer vhost:80 and a node with http includes ' do
    expect('vhost_a:80').to transfer('node_a').http
      .include('X-Test: 1')
    expect('vhost_a:80').to transfer('node_a').http
      .include(/Test:/)
  end

  describe 'request_command' do
    it 'should create single header options for http' do
      expect(Lbspec::Util).to receive(:exec_command)
        .with(/ -H.*/, nil)
      expect(Lbspec::Util).not_to receive(:exec_command)
        .with(/ -H.* -H/, nil)
      expect('vhost_a:443').to transfer('node_a').http
        .options(header: 'X-Test1:1')
    end
    it 'should create single header options for https' do
      expect(Lbspec::Util).to receive(:exec_command)
        .with(/ -H.*/, nil)
      expect(Lbspec::Util).not_to receive(:exec_command)
        .with(/ -H.* -H/, nil)
      expect('vhost_a:443').to transfer('node_a').https
        .options(header: 'X-Test1:1')
    end
    it 'should create multi header options for http' do
      expect(Lbspec::Util).to receive(:exec_command)
        .with(/ -H.* -H/, nil)
      expect('vhost_a:443').to transfer('node_a').http
        .options(header: %w(X-Test1:1 X-Test2:2))
    end
    it 'should create multi header options for https' do
      expect(Lbspec::Util).to receive(:exec_command)
        .with(/ -H.* -H/, nil)
      expect('vhost_a:443').to transfer('node_a').https
        .options(header: %w(X-Test1:1 X-Test2:2))
    end
  end

end
