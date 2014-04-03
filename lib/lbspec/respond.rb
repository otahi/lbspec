# -*- encoding: utf-8 -*-
require 'net/ssh'
require 'rspec/core'
require 'rspec/expectations'
require 'lbspec'

RSpec::Matchers.define :respond do |expect|

  @expect = expect
  @protocol = :tcp
  @application = nil
  @path = nil
  @string = nil
  @chain_str = ''
  @options = {}
  @output_request = ''

  match do |vhost|
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
    @chain_str << ' tcp'
  end

  chain :udp do
    @protocol = :udp
    @application = nil
    @chain_str << ' udp'
  end

  chain :http do
    @protocol = :tcp
    @application = :http
    @chain_str << ' http'
  end

  chain :https do
    @protocol = :tcp
    @application = :https
    @chain_str << ' https'
  end

  chain :from do |from|
    @from = from
    @chain_str << " from #{from}"
  end

  chain :path do |path|
    @path = path
    @chain_str << " via #{path}"
  end

  chain :with do |string|
    @string = string
    @chain_str << " via #{string}"
  end

  chain :options do |options|
    @options = options
  end

  description do
    "respond #{@expect} #{@chain_str}"
  end

  failure_message_for_should do |vhost|
    result =  "expected #{vhost} to respond #{@expect}"
    result << result_string
  end

  failure_message_for_should_not do |vhost|
    result =  "expected #{vhost} not to respond #{@expect}"
    result << result_string
  end

  def result_string
    result =  ", but did.\n" + "requested:\n"
    result << request_str.gsub(/^/, '  ')
  end
end
