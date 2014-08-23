# -*- encoding: utf-8 -*-
require 'net/ssh'
require 'rspec/core'
require 'rspec/expectations'
require 'lbspec'

RSpec::Matchers.define :respond do |expect|
  match do |vhost|
    fail ArgumentError, '#respond must have non-nil argument' unless expect
    log.debug("#respond(#{expect.inspect}) is called")
    @vhost = vhost
    @expect = expect
    request =
      Lbspec::Request.new(vhost, @from,
                          protocol: @protocol, application: @application,
                          path: @path, options: @options)
    @output_request = request.send(@string)
    @output_request.match(expect)
  end

  chain :tcp do
    @protocol = :tcp
    @application = nil
    @chain_str = Lbspec::Util.add_string(@chain_str, ' tcp')
  end

  chain :udp do
    @protocol = :udp
    @application = nil
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

  chain :path do |path|
    fail ArgumentError, '#path must have non-nil argument' unless path
    @path = path
    @chain_str = Lbspec::Util.add_string(@chain_str, " via #{path}")
  end

  chain :with do |string|
    fail ArgumentError, '#with must have non-nil argument' unless string
    @string = string
    @chain_str = Lbspec::Util.add_string(@chain_str, " via #{string}")
  end

  chain :options do |options|
    @options = options
  end

  description do
    "respond #{@expect}#{@chain_str}."
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
    result =  "expected #{@vhost}#{neg_expect} to respond #{@expect}"
    result <<  ", but did#{neg_actual}.\n" + "requested:\n"
    result << @output_request.gsub(/^/, '  ')
  end

  def log
    Lbspec::Util.log
  end
end
