# -*- encoding: utf-8 -*-
require 'net/ssh'
require 'rspec/core'
require 'rspec/expectations'
require 'lbspec'

RSpec::Matchers.define :transfer do |nodes|
  match do |vhost|
    fail ArgumentError, '#transfer must have non-nil argument' unless nodes
    log.debug("#transfer(#{nodes.inspect}) is called")
    @vhost = vhost
    prove = Lbspec::Util.create_prove
    bpf = Lbspec::Capture.bpf(port: @port)
    capture =
      Lbspec::Capture.new(nodes, bpf, prove, @include_str)
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
    fail ArgumentError, '#port must have non-nil argument' unless port
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
    fail ArgumentError, '#from must have non-nil argument' unless from
    @from = from
    @chain_str = Lbspec::Util.add_string(@chain_str, " from #{from}")
  end

  chain :include do |str|
    fail ArgumentError, '#include must have non-nil argument' unless str
    @include_str = str
    @chain_str = Lbspec::Util.add_string(@chain_str, " including #{str}")
  end

  chain :path do |path|
    fail ArgumentError, '#path must have non-nil argument' unless path
    @path = path
    @chain_str = Lbspec::Util.add_string(@chain_str, " via #{path}")
  end

  chain :options do |options|
    @options = options
  end

  description do
    "transfer requests to #{nodes}#{@chain_str}."
  end

  failure_message_for_should do
    result_string
  end

  failure_message_for_should_not do
    negative = true
    result_string(negative)
  end

  def result_string(negative = false)
    neg_expect = negative ? ' not' : ''
    neg_actual = negative ? '' : ' not'
    result =  "expected #{@vhost}#{neg_expect} to transfer requests to"
    result << @nodes.to_s + @chain_str
    result << ", but did#{neg_actual}.\n" + "requested:\n"
    result << @output_request.gsub(/^/, '  ')
    result << "\ncaptured:\n"
    result << result_capture
    result
  end

  def result_capture
    result = ''
    @output_capture.each do |o|
      result << o[:node].gsub(/^/, '  ') + "\n"
      result << o[:output].gsub(/^/, '    ') + "\n"
    end
    result
  end

  def log
    Lbspec::Util.log
  end
end
