require 'spec_helper'

describe 'vhost_a' do
  it { should have_transferred('node_a') }
  it { should have_transferred(['node_c','node_b']) }
end
