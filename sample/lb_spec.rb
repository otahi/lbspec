require_relative 'spec_helper'

describe 'vhost_a' do
  it { should transfer('node_a') }
  it { should transfer(['node_c','node_b']) }
  it 'should test transfer a node on port 80' do
    'vhost_a'.should transfer('node_a:80')
  end
  it 'should test transfer a node on port 8080' do
    'vhost_a'.should_not transfer('node_a:8080')
  end
end
