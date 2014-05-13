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
    'loadbalancer'.should healthcheck('node_a')
  end
  it 'should test loadbalancer healthchecks include string' do
    'loadbalancer'.should healthcheck('node_a').include('X-Test')
  end
  it 'should test loadbalancer healthchecks from specified host' do
    'loadbalancer'.should healthcheck('node_a').from('X-Test')
  end
  it 'should test loadbalancer healthchecks at specified interval' do
    'loadbalancer'.should healthcheck('node_a').interval(5)
  end
  it 'should test loadbalancer healthchecks specified port' do
    'loadbalancer'.should healthcheck('node_a').port(80)
  end
  it 'should test loadbalancer healthchecks icmp' do
    'loadbalancer'.should healthcheck('node_a').icmp
  end
  it 'should test loadbalancer healthchecks tcp' do
    'loadbalancer'.should healthcheck('node_a').tcp
  end
  it 'should test loadbalancer healthchecks udp' do
    'loadbalancer'.should healthcheck('node_a').udp
  end
end
