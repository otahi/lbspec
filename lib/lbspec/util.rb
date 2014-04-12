# -*- encoding: utf-8 -*-
# Lbspec is an RSpec plugin for easy Loadbalancer testing.
module Lbspec
  # Lbspec::Util provides some utilities
  class Util
    def self.add_string(target, addition)
      if target.nil?
        target = addition
      else
        target << addition
      end
    end

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
        # if there is no user for the node in ~/.ssh/config
        # use current user name for login
        user = Net::SSH::Config.for(node)[:user]
        user = `whoami`.chomp unless user
        Net::SSH.start(node, user, config: true, verbose: Logger::WARN) do |ssh|
          output << ssh.exec!(command).to_s
        end
      else
        output << `#{command}`.to_s
      end
    end
  end
end
