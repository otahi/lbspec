require_relative 'spec_helper'

describe 'vhost_a' do
  it { should transfer('node_a') }
  it { should transfer(['node_c','node_b']) }
end
