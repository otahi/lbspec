# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'net/ssh'

describe '#healthcheck' do
  before(:each) do
    include_str = 'X-Test: 1'
    channel_connected = double('channel_connected')
    allow(channel_connected).to receive(:request_pty)
      .and_yield(channel_connected, true)
    allow(channel_connected).to receive(:exec)
      .and_yield(channel_connected, nil, nil)
    allow(channel_connected).to receive(:on_data)
      .and_yield(nil, include_str)
      .and_yield(nil, include_str)
    ssh_connected = double('ssh_connected')
    allow(ssh_connected).to receive(:open_channel).and_yield(channel_connected)
    allow(ssh_connected).to receive(:closed?).and_return(false)
    allow(ssh_connected).to receive(:close)
    allow(ssh_connected).to receive(:exec!).and_return(true)
    allow(Net::SSH).to receive(:start).and_yield(ssh_connected)
      .and_return(ssh_connected)
    allow(Kernel).to receive(:system).and_return true
    allow(Kernel).to receive(:`).and_return(include_str) # `
  end

  it 'should test loadbalancer healthchecks' do
    expect('loadbalancer').to healthcheck('node_a')
  end
  it 'should test loadbalancer healthchecks include string' do
    expect('loadbalancer').to healthcheck('node_a').include('X-Test')
  end
  it 'should test loadbalancer healthchecks from specified host' do
    expect('loadbalancer').to healthcheck('node_a').from('X-Test')
  end
  it 'should test loadbalancer healthchecks at specified interval' do
    expect('loadbalancer').to healthcheck('node_a').interval(5)
  end
  it 'should test loadbalancer healthchecks specified port' do
    expect('loadbalancer').to healthcheck('node_a').port(80)
  end
  it 'should test loadbalancer healthchecks icmp' do
    expect('loadbalancer').to healthcheck('node_a').icmp
  end
  it 'should test loadbalancer healthchecks tcp' do
    expect('loadbalancer').to healthcheck('node_a').tcp
  end
  it 'should test loadbalancer healthchecks udp' do
    expect('loadbalancer').to healthcheck('node_a').udp
  end
end
