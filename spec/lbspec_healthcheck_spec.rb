# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'net/ssh'

describe '#healthcheck' do
  before(:each) do
    include_str = 'X-Test: 1'
    channel_connected = double('channel_connected')
    channel_connected.stub(:request_pty).and_yield(channel_connected, true)
    channel_connected.stub(:exec).and_yield(channel_connected, nil, nil)
    channel_connected.stub(:on_data)
      .and_yield(nil, include_str)
      .and_yield(nil, include_str)
    ssh_connected = double('ssh_connected')
    ssh_connected.stub(:open_channel).and_yield(channel_connected)
    ssh_connected.stub(:closed?).and_return(false)
    ssh_connected.stub(:close)
    ssh_connected.stub(:exec!).and_return(true)
    Net::SSH.stub(:start).and_yield(ssh_connected).and_return(ssh_connected)
    Kernel.stub(:system).and_return true
    Kernel.stub(:`).and_return(include_str) # `
  end

  it 'should test loadbalancer healthchecks' do
    Lbspec::Util.stub(:exec_command).and_return '200 OK'
    'loadbalancer'.should healthcheck('node_a')
  end
end
