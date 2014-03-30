# -*- encoding: utf-8 -*-
require 'lbspec'

# Lbspec is an RSpec plugin for easy Loadbalancer testing.
module Lbspec
  # Lbspec::Request reqresent of request
  class Request
    @request_host = nil
    @protocol = nil
    @application = nil
    @path = '/'
    @port = 80
    @options = {}

    def initialize(target, request_host, options = {})
      addr_port = Lbspec::Util.split_addr_port(target.to_s)
      @addr, @port = addr_port[:addr], addr_port[:port]
      @request_host = request_host
      @protocol = options[:protocol] ? options[:protocol] : nil
      @application = options[:application] ? options[:application] : nil
      @path = options[:path] ? options[:path] : '/'
      @port = options[:port] ? options[:port] : 80
      @options = options[:options] ? options[:options] : {}
    end

    def send(prove)
      if @application
        send_application(prove)
      else
        send_transport(prove)
      end
    end

    private

    def send_application(prove)
      case @application
      when :http
        uri = 'http://' + "#{@addr}:#{@port}#{@path}?#{prove}"
        command = build_curl_command(uri, @options)
        Lbspec::Util.exec_command(command, @request_host)
      when :https
        uri = 'https://' + "#{@addr}:#{@port}#{@path}?#{prove}"
        command = build_curl_command(uri, @options)
        Lbspec::Util.exec_command(command, @request_host)
      end
    end

    def build_curl_command(uri, options = {})
      env, opt = '', ''
      opt << (options[:timeout] ? " -m #{options[:timeout]}" : '')
      opt << (options[:ignore_valid_ssl] ? ' -k' : '')
      opt << (options[:proxy] ? %Q( -x "#{options[:proxy]}") : '')
      if options[:noproxy]
        env << %Q( no_proxy="#{options[:noproxy]}")
        env << %Q( NO_PROXY="#{options[:noproxy]}")
      end
      opt << header_option(options[:header])
      %Q(#{env} curl -o /dev/null -s #{opt} '#{uri}')
    end

    def header_option(header)
      opt = ''
      header = [header] unless header.respond_to? :each
      header.each { |h| opt << %Q( -H '#{h}') }
      opt
    end

    def send_transport(prove)
      case @protocol
      when :udp
        Lbspec::Util
          .exec_command("echo #{prove} | nc -u #{@addr} #{@port}",
                        @request_host)
      else
        Lbspec::Util
          .exec_command("echo #{prove} | nc #{@addr} #{@port}",
                        @request_host)
      end
    end
  end
end
