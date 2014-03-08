# -*- encoding: utf-8 -*-
# Lbspec is an RSpec plugin for easy Loadbalancer testing.
module Lbspec
  # Lbspec::Util provides some utilities
  class Util
    def self.gen_keyword
      t = Time.now
      t.to_i.to_s + t.nsec.to_s
    end
  end
end
