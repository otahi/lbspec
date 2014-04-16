# -*- encoding: utf-8 -*-
require 'net/ssh'
require 'rspec/core'
require 'rspec/expectations'
require 'lbspec'

RSpec::Matchers.define :respond do |expect|
  match do |vhost|
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
    @from = from
    @chain_str = Lbspec::Util.add_string(@chain_str, " from #{from}")
  end

  chain :path do |path|
    @path = path
    @chain_str = Lbspec::Util.add_string(@chain_str, " via #{path}")
  end

  chain :with do |string|
    @string = string
    @chain_str = Lbspec::Util.add_string(@chain_str, " via #{string}")
  end

  chain :options do |options|
    @options = options
  end

  description do
    "respond #{@expect}#{@chain_str}."
  end

  failure_message_for_should do |vhost|
    result_string(vhost, @expect)
  end

  failure_message_for_should_not do |vhost|
    negative = true
    result_string(vhost, @expect, negative)
  end

  def result_string(vhost, expect, negative = false)
    negation = negative ? ' not' : ''
    result =  "expected #{vhost}#{negation} to respond #{expect}"
    result <<  ", but did#{negation}.\n" + "requested:\n"
    result << request_str.gsub(/^/, '  ')
  end
end
