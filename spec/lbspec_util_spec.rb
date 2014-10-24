# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'net/ssh'
require 'logger'

describe Lbspec::Util do
  describe '#logger' do
    it 'should set/get logger' do
      Lbspec::Util.logger = 'test'
      expect(Lbspec::Util.logger).to eql('test')
    end
  end
  describe '#log_level' do
    it 'should set/get log_level' do
      Lbspec::Util.log_level = Logger::WARN
      expect(Lbspec::Util.log_level).to eql(Logger::WARN)
    end
  end
  describe '#log' do
    before :each do
      Lbspec::Util.logger = nil
    end
    it 'should return Logger instance' do
      expect(Lbspec::Util.log).to be_instance_of(Logger)
    end
  end
end
