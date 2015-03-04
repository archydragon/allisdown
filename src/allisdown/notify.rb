#!/usr/bin/env ruby -wKU
# encoding: utf-8

# # # Notifications using email and HTTP APIs

require 'pony' # /o\
require 'net/http'
require 'uri'

class Notify
  def initialize(cfg)
    @method = cfg['method']
    @config = cfg
  end

  public

  # 'data' parameter for all public methods contain the following map:
  #   item => the title of the checked host from configuration
  #   host => hostname/ip
  #   status => the latest returned status string
  #   timestamp => timestamp of the latest check

  def sendmail(data)
    subj = "#{data['item']} - #{data['status']}"
    body = "Host: #{data['host']}\nStatus: #{data['status']}\n" +
           "Checked at: #{Time.at(data['timestamp'])}"
    Pony.mail(:to => @config['target'],
              :from => @config['from'],
              :via => :sendmail,
              :subject => subj,
              :body => body)
  end

  def smtp(data)
    subj = "#{data['item']} - #{data['status']}"
    body = "Host: #{data['host']}\nStatus: #{data['status']}\n" +
           "Checked at: #{Time.at(data['timestamp'])}"
    Pony.mail({:to => @config['target'],
               :from => @config['from'],
               :via => :smtp,
               :via_options => {
                 :address => @config['smtp_server'],
                 :port => @config['smtp_port'],
                 :user_name => @config['smtp_user'],
                 :password => @config['smtp_password'],
                 :authentication => :plain,
                 :ssl => @config['smtp_ssl'],
                 :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
               },
               :subject => subj,
               :body => body})
  end

  def post(data)
    body = @config['format'].gsub(/#/, "Host: #{data['host']}\nStatus: " +
           "#{data['status']}\nChecked at: #{Time.at(data['timestamp'])}")
    uri = URI.parse(@config['url'])
    Net::HTTP.post_form(uri, {@config['field'] => body})
  end

end
