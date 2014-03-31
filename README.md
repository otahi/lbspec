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

## Functions
You can use lbspec to test load balancers.

### #transfer
`#transfer` tests if a virtual host on a load balancer transfer requests to target nodes.

#### chains
You can use following chains with `#transfer`.

- port
  - Tests if a virtual host transfers requests to specified port on target nodes.
- include
  - Tests if a virtual host transfers requests include string.
- tcp
  - Tests with tcp packets for the virtual host.
- udp
  - Tests with udp packets for the virtual host.
- http
  - Tests with an http request for the virtual host.
- https
  - Tests with an https request for the virtual host.
- from
  - Specifies which host sends to the virtual host.
- path
  - Specifies a path for http or https requests.
- options
  - Options which can be used in http or https request commands.
  - You can use `options` if you configure request commands or capture commands.

### #respond
`#respond` tests if a virtual host on a load balancer respond as same as expected.

#### chains
You can use following chains with `#respond`.

- tcp
  - Tests with tcp packets for the virtual host.
- udp
  - Tests with udp packets for the virtual host.
- http
  - Tests with an http request for the virtual host.
- https
  - Tests with an https request for the virtual host.
- from
  - Specifies which host sends to the virtual host.
- path
  - Specifies a path for http or https requests.
- with
  - Specifies a string included in requests.
- options
  - Options which can be used in http or https request commands.
  - You can use `options` if you configure request commands or capture commands.


## Requires
* Users need to be able to login with ssh to the target nodes.
* Users need to be able to `sudo` on the target nodes.
* Netcat and curl are needed on requesting host.
* Grep and ngrep are needed on capturing host.

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
  it { should respond('200 OK') }
end

describe 'vhost_b' do
  it { should transfer(['node_b','node_c']) }
  it { should respond('200 OK') }
end

describe 'vhost_c:80' do
  it { should transfer(['node_b','node_c']).port(80) }
  it { should respond('404') }
end

describe 'vhost_c:80' do
  it { should transfer(['node_b','node_c']).port(53).udp }
end

describe 'vhost_c:80/test/' do
  it { should transfer('node_c').http }
  it { should respond('200 OK').http }
end

describe 'vhost_c:443' do
  it { should transfer(['node_b','node_c']).port(80).https.path('/test/' }
  it { should respond('200 OK').https.path('/test/') }
end

describe 'vhost_c:443/test/' do
  it do
    should transfer(['node_b','node_c']).port(80).https
      .options(ignore_valid_ssl: true)
  end
  it do should respond('200 OK').path('/test/').https
      .options(ignore_valid_ssl: true)
  end
end

describe 'vhost_c:80/test/' do
  it { should transfer('node_c').http.from('node_a') }
end

```
## How it works
### #transfer

 1. ssh to nodes
   - ssh to the nodes which receive requests via the target virtual host
 2. capture probe
   - capture packets on the nodes 
 3. access to the nodes with probe
   - netcat or curl to the virtual host with prove
 4. judge
   - judge if expected request are captured on the capturing nodes

![#tranfer works][1]

## Contributing

1. Fork it ( http://github.com/otahi/lbspec/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


  [1]: images/transfer_overview.gif
