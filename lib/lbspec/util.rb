# -*- encoding: utf-8 -*-
# Lbspec is an RSpec plugin for easy Loadbalancer testing.
module Lbspec
  # Lbspec::Util provides some utilities
  class Util
    def self.create_prove
      t = Time.now
      t.to_i.to_s + t.nsec.to_s
    end
    def self.split_addr_port(addr_port_str)
      port = 0
      splits = addr_port_str.split(':')
      addr = splits.first
      port = splits.last.to_i if /\d+/ =~ splits.last
      { addr: addr, port: port }
    end
    def self.build_curl_command(uri, options)
      env, opt = '', ''
      opt << (options[:timeout] ? " -m #{options[:timeout]}" : '')
      opt << (options[:ignore_valid_ssl] ? ' -k' : '')
      opt << (options[:proxy] ? %Q( -x "#{options[:proxy]}") : '')
      if options[:noproxy]
        env << %Q( no_proxy="#{options[:noproxy]}")
        env << %Q( NO_PROXY="#{options[:noproxy]}")
      end
      opt << header_option(options[:header])
      %Q(#{env} curl -o /dev/null -s #{opt} '#{uri}')
    end
    def self.header_option(header)
      opt = ''
      header = [header] unless header.respond_to? :each
      header.each { |h| opt << %Q( -H '#{h}') }
      opt
    end
    def self.exec_command(command, node = nil)
      output = command
      if node
        Net::SSH.start(node, nil, config: true) do |ssh|
          output << ssh.exec!(command).to_s
        end
      else
        output << `#{command}`.to_s
      end
    end
  end
end
