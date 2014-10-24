# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'net/ssh'

describe '#respond' do

  context 'http/https' do
    it 'should test vhost_a responds with 200 OK' do
      allow(Lbspec::Util).to receive(:exec_command).and_return '200 OK'
      expect('vhost_a').to respond('200 OK')
    end
    it 'should test vhost:80 responds with 200 OK by request with options' do
      allow(Lbspec::Util).to receive(:exec_command).and_return '200 OK'
      expect('vhost_a:443').to respond('200 OK').http.path('/test')
    end
    it 'should test vhost:443 responds with 404 by request with options' do
      allow(Lbspec::Util).to receive(:exec_command).and_return '404 Not Found'
      expect('vhost_a:443').to respond('404').https.path('/test')
        .options(ignore_valid_ssl: false, timeout: 5)
    end
    it 'should test vhost:443 responds by requests from specified host' do
      allow(Lbspec::Util).to receive(:exec_command).and_return '200 OK'
      expect('vhost_a:443').to respond('200 OK')
        .https.path('/test').from('node_a')
    end
    it 'should test vhost:443 does not respond 404' do
      allow(Lbspec::Util).to receive(:exec_command).and_return '200 OK'
      expect('vhost_a:443').to_not respond('404')
        .https.path('/test').from('node_a')
    end
    it 'should test vhost:443/test does not respond 404' do
      allow(Lbspec::Util).to receive(:exec_command).and_return '200 OK'
      expect('vhost_a:443/test').to_not respond('404')
        .https.from('node_a')
    end
    it 'should test vhost:443/test does not respond 404' do
      allow(Lbspec::Util).to receive(:exec_command).and_return '200 OK'
      expect('vhost_a:443/test').to_not respond('404')
        .https.from('node_a')
    end
    it 'should test vhost:443/test does respond /^404/' do
      allow(Lbspec::Util).to receive(:exec_command).and_return '404 Not Found'
      expect('vhost_a:443/test').to respond(/^404/)
        .https.from('node_a')
    end
  end
  context 'tcp/udp' do
    it 'should test vhost:25/tcp respond 220' do
      allow(Lbspec::Util).to receive(:exec_command).and_return '220'
      expect('vhost_a:25').to respond('220')
        .tcp.with('HELO test.example.com')
    end
    it 'should test vhost:53/udp respond ' do
      allow(Lbspec::Util).to receive(:exec_command).and_return '220'
      expect('vhost_a:53').to respond('220')
        .udp.with('HELO test.example.com')
    end
  end
  context 'description works with 200 OK' do
    subject { 'vhost_a' }
    it  do
      allow(Lbspec::Util).to receive(:exec_command).and_return '200 OK'
      is_expected.to respond('200 OK')
    end
  end
end
