# Lbspec

Lbspec is an RSpec plugin for easy Loadbalancer testing.

[![Build Status](https://travis-ci.org/otahi/lbspec.png?branch=master)](https://travis-ci.org/otahi/lbspec)
[![Coverage Status](https://coveralls.io/repos/otahi/lbspec/badge.png?branch=master)](https://coveralls.io/r/otahi/lbspec?branch=master)
[![Gem Version](https://badge.fury.io/rb/lbspec.png)](http://badge.fury.io/rb/lbspec)
## Installation

Add this line to your application's Gemfile:

    gem 'lbspec'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install lbspec

## Requires
* Users need to be able to login with ssh to the target nodes.
* Users need to be able to `sudo` on the target nodes.
* netcat and ngrep are needed to be installed.

## Limitations
* Lbspec uses only ssh configuration in ~/.ssh/config

## Usage

Lbspec is best described by example. First, require `lbspec` in your `spec_helper.rb`:

```ruby
# spec/spec_helper.rb
require 'rspec'
require 'lbspec'
```

Then, create a spec like this:

```ruby
require_relative 'spec_helper'

describe 'vhost_a' do
  it { should transfer('node_a') }
end

describe 'vhost_b' do
  it { should transfer(['node_b','node_c']) }
end

describe 'vhost_c:80' do
  it { should transfer(['node_b','node_c']).port(80) }
end

describe 'vhost_c:80' do
  it { should transfer(['node_b','node_c']).port(53).udp }
end

describe 'vhost_c:80' do
  it { should transfer('node_c').http.path('/test/') }
end

describe 'vhost_c:443' do
  it { should transfer(['node_b','node_c']).port(80).https.path('/test/') }
end

```

## Contributing

1. Fork it ( http://github.com/otahi/lbspec/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
