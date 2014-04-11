# -*- encoding: utf-8 -*-
require 'net/ssh'
require 'rspec/core'
require 'rspec/expectations'
require 'lbspec'

RSpec::Matchers.define :transfer do |nodes|
  match do |vhost|
    prove = Lbspec::Util.create_prove
    capture =
      Lbspec::Capture.new(nodes, @port, prove, @include_str)
    capture.open
    request =
      Lbspec::Request.new(vhost, @from,
                          protocol: @protocol, application: @application,
                          path: @path, options: @options)
    @output_request = request.send(prove)
    @output_capture = capture.output
    capture.close
    capture.result
  end

  chain :port do |port|
    @port = port
    @chain_str = Lbspec::Util.add_string(@chain_str, " port #{port}")
  end

  chain :tcp do
    @protocol = :tcp
    @chain_str = Lbspec::Util.add_string(@chain_str, ' tcp')
  end

  chain :udp do
    @protocol = :udp
    @chain_str = Lbspec::Util.add_string(@chain_str, ' udp')
  end

  chain :http do
    @protocol = :tcp
    @application = :http
    @chain_str = Lbspec::Util.add_string(@chain_str, ' http')
  end

  chain :https do
    @protocol = :tcp
    @application = :https
    @chain_str = Lbspec::Util.add_string(@chain_str, ' https')
  end

  chain :from do |from|
    @from = from
    @chain_str = Lbspec::Util.add_string(@chain_str, " from #{from}")
  end

  chain :include do |str|
    @include_str = str
    @chain_str = Lbspec::Util.add_string(@chain_str, " including #{str}")
  end

  chain :path do |path|
    @path = path
    @chain_str = Lbspec::Util.add_string(@chain_str, " via #{path}")
  end

  chain :options do |options|
    @options = options
  end

  description do
    "transfer requests to #{nodes}#{@chain_str}."
  end

  failure_message_for_should do |vhost|
    result =  "expected #{vhost} to transfer requests to"
    result <<
      result_string(nodes, @chain_str, @output_request, @output_capture)
  end

  failure_message_for_should_not do |vhost|
    result =  "expected #{vhost} not to transfer requests to"
    result <<
      result_string(nodes, @chain_str, @output_request, @output_capture)
  end

  def result_string(nodes, chain_str, request_str, capture_str)
    result = nodes.to_s + chain_str
    result << ", but did.\n" + "requested:\n"
    result << request_str.gsub(/^/, '  ')
    result << "\ncaptured:\n"
    @output_capture.each do |o|
      result << o[:node].gsub(/^/, '  ') + "\n"
      result << o[:output].gsub(/^/, '    ') + "\n"
    end
    result
  end
end
