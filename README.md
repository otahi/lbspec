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
- path
  - Specifies a path for http or https requests.
- from
  - Specifies which host sends to the virtual host.
- options
  - Options which can be used in http or https request commands.
  - You can use `options` if you configure request commands or capture commands.

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

describe 'vhost_c:443' do
  it do
    should transfer(['node_b','node_c']).port(80).https.path('/test/')
      .options(ignore_valid_ssl: true)
  end
end

describe 'vhost_c:80' do
  it { should transfer('node_c').http.path('/test/').from('node_a') }
end

```
## How it works
### #transfer

 1. ssh to nodes
 2. cupture probe
 3. access with probe
 4. judge

![#tranfer works][1]


## Configuration
### #transfer
You can change how to capture probes and access to `vhost` with probes. You can replace default procedures to your procedures in spec_helpers or .spec files as follows. If you use `Lbspec::Util.exec_command()`, you can specify the node which generate request.
```ruby
RSpec.configuration.lbspec_capture_command =
  lambda do |port, prove|
  port_str = port > 0 ? "port #{port}" : ''
  "sudo ngrep #{prove} #{port_str} | grep -v \"match:\""
end

RSpec.configuration.lbspec_https_request_command =
  lambda do |addr, port, path, prove|
  uri = 'https://' + "#{addr}:#{port}#{path}?#{prove}"
  Lbspec::Util.exec_command("curl -o /dev/null -sk #{uri}", @request_node)
end
```
You can also use the procedures with `options` with a chain `options`.
```ruby
RSpec.configuration.lbspec_https_request_command =
  lambda do |addr, port, path, prove|
  opt =  @options[:timeout] ? " -m #{@options[:timeout]}" : ''
  opt << (@options[:ignore_valid_ssl] ? ' -k' : '')
  Lbspec::Util.exec_command("curl -o /dev/null -s #{opt} #{uri}", @request_node)
end
```

You can replace following items.

 - `lbspec_capture_command` with `|port, prove|`
 - `lbspec_udp_request_command` with `|addr, port, prove|`
 - `lbspec_tcp_request_command` with `|addr, port, prove|`
 - `lbspec_http_request_command` with `|addr, port, path, prove|`
 - `lbspec_https_request_command` with `|addr, port, path, prove|`

## Contributing

1. Fork it ( http://github.com/otahi/lbspec/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


  [1]: images/transfer_overview.gif
