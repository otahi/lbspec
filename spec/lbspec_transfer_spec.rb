# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'net/ssh'

describe Lbspec do
  describe '#transfer' do
    before(:each) do
      key = Lbspec::Util.create_prove
      Lbspec::Util.stub(:create_prove).and_return(key)
      channel_connected = double('channel_connected')
      channel_connected.stub(:request_pty).and_yield(channel_connected, true)
      channel_connected.stub(:exec).and_yield(channel_connected, nil, nil)
      channel_connected.stub(:on_data).and_yield(nil, key).and_yield(nil, key)
      ssh_connected = double('ssh_connected')
      ssh_connected.stub(:open_channel).and_yield(channel_connected)
      ssh_connected.stub(:closed?).and_return(false)
      ssh_connected.stub(:close)
      Net::SSH.stub(:start).and_yield(ssh_connected).and_return(ssh_connected)
      Kernel.stub(:system).and_return true
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
      'vhost_a:443'.should transfer('node_a').https.path('/test')
    end
    describe 'vhost_a:443' do
      it { should transfer('node_a').https.path('/test') }
      it { should transfer('node_a').port(80).tcp.https.path('/test') }
    end
    describe 'vhost_a:443' do
      it do
        should transfer('node_a').https.path('/test')
          .options(ignore_valid_ssl: true)
      end
      it do
        should transfer('node_a').https.path('/test')
          .options(timeout: 5)
      end
    end
  end
end
