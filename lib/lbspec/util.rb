# -*- encoding: utf-8 -*-
# Lbspec is an RSpec plugin for easy Loadbalancer testing.
module Lbspec
  # Lbspec::Util provides some utilities
  class Util
    def self.create_prove
      t = Time.now
      t.to_i.to_s + t.nsec.to_s
    end

    def self.split_addr_port_path(addr_port_path)
      splits = addr_port_path.split(/[:\/]/)
      addr = splits[0]
      port = (/\d+/ =~ splits[1]) ? splits[1].to_i : nil
      path = (/\d+/ =~ splits[1]) ? '/' + splits[2].to_s : '/' + splits[1].to_s
      [addr, port, path]
    end

    def self.exec_command(command, node = nil)
      output = command + "\n"
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
