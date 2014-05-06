# -*- encoding: utf-8 -*-
require 'net/ssh'
require 'rspec/core'
require 'rspec/expectations'
require 'lbspec'

RSpec::Matchers.define :healthcheck do |nodes|

  @include_str = nil
  @port = 0
  @path = nil
  @chain_str = ''
  @options = {}
  @output_request = ''
  @output_capture = ''

  match do
    capture =
      Lbspec::Capture.new(nodes, @port, nil, @include_str)
    capture.open
    capture.close
    capture.result
  end

  chain :include do |str|
    @include_str = str
    @chain_str << " including #{str}"
  end

  chain :from do |from|
    @from = from
    @chain_str << " from #{from}"
  end

  chain :interval do |second|
    @interval = second
    @chain_str << " at interval of #{second} sec"
  end

  chain :port do |port|
    @port = port
    @chain_str << " port #{port}"
  end

  chain :icmp do
    @protocol = :icmp
    @chain_str << ' icmp'
  end

  chain :tcp do
    @protocol = :tcp
    @chain_str << ' tcp'
  end

  chain :udp do
    @protocol = :udp
    @chain_str << ' udp'
  end

  chain :options do |options|
    @options = options
  end

  description do
    "healthcheck #{nodes}#{@chain_str}."
  end

  failure_message_for_should do
    result_string
  end

  failure_message_for_should_not do
    negative = true
    result_string(negative)
  end

  def result_string(negative = false)
    negation = negative ? ' not' : ''
    result = "expected #{lb} to healthcheck to"
    result << nodes.to_s + chain_str
    result << ", but did#{negation}.\n"
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
end
