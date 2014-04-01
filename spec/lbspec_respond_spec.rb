# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'net/ssh'

describe Lbspec do
  describe '#respond' do

    context 'http/https' do
      it 'should test vhost_a responds with 200 OK' do
        Lbspec::Util.stub(:exec_command).and_return '200 OK'
        'vhost_a'.should respond('200 OK')
      end
      it 'should test vhost:80 responds with 200 OK by request with options' do
        Lbspec::Util.stub(:exec_command).and_return '200 OK'
        'vhost_a:443'.should respond('200 OK').http.path('/test')
      end
      it 'should test vhost:443 responds with 404 by request with options' do
        Lbspec::Util.stub(:exec_command).and_return '404 Not Found'
        'vhost_a:443'.should respond('404').https.path('/test')
          .options(ignore_valid_ssl: false, timeout: 5)
      end
      it 'should test vhost:443 responds by requests from specified host' do
        Lbspec::Util.stub(:exec_command).and_return '200 OK'
        'vhost_a:443'.should respond('200 OK')
          .https.path('/test').from('node_a')
      end
      it 'should test vhost:443 does not respond 404' do
        Lbspec::Util.stub(:exec_command).and_return '200 OK'
        'vhost_a:443'.should_not respond('404')
          .https.path('/test').from('node_a')
      end
      it 'should test vhost:443/test does not respond 404' do
        Lbspec::Util.stub(:exec_command).and_return '200 OK'
        'vhost_a:443/test'.should_not respond('404')
          .https.from('node_a')
      end
      it 'should test vhost:443/test does not respond 404' do
        Lbspec::Util.stub(:exec_command).and_return '200 OK'
        'vhost_a:443/test'.should_not respond('404')
          .https.from('node_a')
      end
    end
    context 'tcp/udp' do
      it 'should test vhost:25/tcp respond 220' do
        Lbspec::Util.stub(:exec_command).and_return '220'
        'vhost_a:25'.should respond('220')
          .tcp.with('HELO test.example.com')
      end
      it 'should test vhost:53/udp respond ' do
        Lbspec::Util.stub(:exec_command).and_return '220'
        'vhost_a:25'.should respond('220')
          .udp.with('HELO test.example.com')
      end
    end
    context 'description works with 200 OK' do
      subject { 'vhost_a' }
      it  do
        Lbspec::Util.stub(:exec_command).and_return '200 OK'
        should respond('200 OK')
      end
    end
  end
end
