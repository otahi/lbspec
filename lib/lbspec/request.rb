# -*- encoding: utf-8 -*-
require 'lbspec'

# Lbspec is an RSpec plugin for easy Loadbalancer testing.
module Lbspec
  # Lbspec::Request reqresent of request
  class Request
    def initialize(target, from = nil, options = {})
      @addr, @port, @path =
        Lbspec::Util.split_addr_port_path(target)
      @from = from
      @protocol = options[:protocol] ? options[:protocol] : nil
      @application = options[:application] ? options[:application] : nil
      @path = options[:path] if options[:path]
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
        send_http(prove)
      when :https
        send_https(prove)
      end
    end

    def send_http(prove)
      @port = 80 unless @port
      uri = 'http://' + "#{@addr}:#{@port}#{@path}?#{prove}"
      command = build_curl_command(uri, @options)
      Lbspec::Util.exec_command(command, @from)
    end

    def send_https(prove)
      @port = 443 unless @port == 0
      uri = 'https://' + "#{@addr}:#{@port}#{@path}?#{prove}"
      command = build_curl_command(uri, @options)
      Lbspec::Util.exec_command(command, @from)
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
        send_udp(prove)
      else
        send_tcp(prove)
      end
    end

    def send_udp(prove)
      @port = 53 unless @port
      Lbspec::Util
        .exec_command("echo #{prove} | nc -u #{@addr} #{@port}", @from)
    end

    def send_tcp(prove)
      @port = 80 unless @port
      Lbspec::Util
        .exec_command("echo #{prove} | nc #{@addr} #{@port}", @from)
    end
  end
end
