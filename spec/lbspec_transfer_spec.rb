require 'spec_helper'

describe Lbspec do
  describe '#transfer' do
    it 'should test transfer a node' do
      'vhost_a'.should transfer('node_a')
    end
    it 'should test transfer nodes' do
      'vhost_a'.should transfer(['node_a','node_b'])
    end
  end
end
