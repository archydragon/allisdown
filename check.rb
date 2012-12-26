#!/usr/bin/env ruby -wKU
# encoding: utf-8

# # # allisdown/check.rb
# # # A set of host check methods
# # # Last updated: 2012-12-26, Mendor (for the details see changelog and git commit history)

require 'uri'
require 'net/http'
require 'net/https'
require 'socket'

module Check

  ## HTTP check
  def self.http(host, port)
    status = ""
    uri = URI("http://#{host}:#{port}")
    begin
      response = Net::HTTP.get_response(uri)
    rescue SocketError => se
      status = "Socket error: #{se}"
    rescue => err
      status = "#{err}"
    end
    if status == ""
      # HTTP errors 5** are errors, sorry for the obvious
      if response.code.to_i >= 500
        status = "HTTP error #{response.code}"
      else
        status = "OK"
      end
    end
    status
  end

  ## HTTPS check
  def self.https(host, port)
    status = ""
    uri = URI.parse("https://#{host}:#{port}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    # we need this to check hosts with unverified SSL certificates
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    begin
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
    rescue SocketError => se
      status = "Socket error: #{se}"
    rescue => err
      status = err.to_s
    end
    if status == ""
      # HTTP errors 5** are errors, sorry for the obvious
      if response.code.to_i >= 500
        status = "HTTP error #{response.code}"
      else
        status = "OK"
      end
    end
    status
  end

  ## TCP port check
  def self.port(host, port)
    status = ""
    begin
      sock = TCPSocket.open(host, port)
    rescue => err
      status = err.to_s
    end
    # if exception hasn't been caught, the port is open
    if status == ""
      status = "OK"
    end
    status
  end

  # ICMP echo check
  def self.ping(host, iters)
    # since Net::Ping::ICMP requires root privileges, I was forced to use dirty system calls
    @safe = 30  # percentage of packet may be lost until it warns
    status = ""
    sysping = `ping -c #{iters} #{host} | grep transmitted | awk -F',' '{print $3}' | sed 's/[^0-9]*//g'`
    pinged = sysping.to_i <= @safe
    if pinged
      status = "OK"
    else
      status = "Packet loss: #{sysping}%"
    end
    status
  end

end
