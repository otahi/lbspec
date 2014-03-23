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
    def self.exec_command(command, node = nil)
      if node
        Net::SSH.start(node, nil, config: true) do |ssh|
          ssh.exec!(command)
        end
      else
        `#{command}`
      end
    end
  end
end
