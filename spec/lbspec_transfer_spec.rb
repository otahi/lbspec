# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'net/ssh'

describe Lbspec do
  describe '#transfer' do
    before(:each) do
      key = Lbspec::Util.gen_keyword
      Lbspec::Util.stub(:gen_keyword).and_return(key)
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
      'vhost_a'.should transfer(%w{node_a node_b})
    end
    it 'should test transfer a node on port 80' do
      'vhost_a'.should transfer('node_a').port(80)
    end
    it 'should test transfer vhost:80 and a node on port 80' do
      'vhost_a:80'.should transfer('node_a').port(80)
    end
  end
end
