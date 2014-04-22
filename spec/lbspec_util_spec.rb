# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'net/ssh'
require 'logger'

describe Lbspec::Util do
  describe '#logger' do
    it 'should set/get logger' do
      Lbspec::Util.logger = 'test'
      Lbspec::Util.logger.should eql('test')
    end
  end
  describe '#log' do
    before :each do
      Lbspec::Util.logger = nil
    end
    it 'should return Logger instance' do
      Lbspec::Util.log.should be_instance_of(Logger)
    end
  end
end
