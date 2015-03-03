#!/usr/bin/env ruby -wKU
# encoding: utf-8

# # # Main class for monitoring module

require 'yaml'
require 'date'
require 'fileutils'
require './check.rb'     # source of the module Check
require './validate.rb'  # source of the module Validate

############   HERE BE DRAGONS   ############

class Monitor
  # default configuration values
  @@CONFIG     = 'conf/monitor.conf.yml'  # main monitoring configuration
  @@FRONTEND   = 'tmp/data.yml'           # file with check results used by frontend
  @@MAINLOG    = 'log/monitor.log'        # main log with all events
  @@HOSTS      = 'conf/hosts.conf.yml'    # file with hosts configuration
  @@TIMEOUT    = 5                        # timeout between check attempts iterations
  @@STATUSFILE = 'tmp/monitor.active'     # lock-file showing monitoring activity
  # hosts data
  @@HOSTDATA   = ''
  @@TOTAL      = 0

  # private methods section
  private

  ## Writing log events
  def self.log(content)
    time = DateTime.now.strftime("%F %T %z")
    File.open(@@MAINLOG, 'a') do |logfile|
      logfile.puts "#{time} - #{content}"
    end
  end

  ## Generate output for frontend
  def self.gendata(type, content)
    if type == 'error'
      # if we got an error, we need also to log it
      self.log("ERROR: #{content}")
      File.open(@@FRONTEND, 'w') do |frontend|
        frontend.puts ['error' => content].to_yaml
      end
    else
      File.open(@@FRONTEND, 'w') do |frontend|
        frontend.puts content.to_yaml
      end
    end
  end

  ## Load configuration data
  def self.config_load?
    if !File.exist?(@@CONFIG)
      self.gendata('error', "Unable load configuration file #{@@CONFIG}")
      return false
    end
    config = YAML.load_file(@@CONFIG)
    # ====== data read — start ======
    @@STATUSFILE = config['statusfile']
    @@FRONTEND   = config['frontend']
    @@HOSTS      = config['hosts']
    @@MAINLOG    = config['mainlog']
    @@TIMEOUT    = config['timeout']
    # ====== data read — end ======
    self.log("Loaded configuration file #{@@CONFIG}")
    true
  end

  ## Validate hosts' configuration
  def self.hosts_validate(hostdata)
    hostdata.each do |key, host|
      # by defaults, current host is valid
      host_valid = true
      bad_params = ""
      # 'host' and 'timeout' keys are required for all check types
      if !Validate.host?(host['host'])
        host_valid = false
        bad_params += " host"
      end
      if !Validate.timeout?(host['timeout'])
        host_valid = false
        bad_params += " timeout"
      end
      case host['type']
      when 'http'
        # for HTTP we optionaly require port number
        if (!Validate.port?(host['port'], false))
          host_valid = false
          bad_params += " port"
        end
      when 'https'
        # for HTTPS we optionaly require port number
        if (!Validate.port?(host['port'], false))
          host_valid = false
          bad_params += " port"
        end
      when 'ping'
        # for ping we strongly require number of iterations
        if (!Validate.port?(host['iters'], true))
          host_valid = false
          bad_params += " iters"
        end
      when 'port'
        # for port we strongly require port number
        if (!Validate.port?(host['port'], true))
          host_valid = false
          bad_params += " port"
        end
      else
        host_valid = false
      end
      # I don't think we need to validate description
      if !host_valid
        self.gendata('error', "Bad configuration for host: #{key} (options:#{bad_params})")
        hostdata.delete(key)
      end
    end
  end

  ## Load hosts data
  def self.hosts_load?
    if !File.exist?(@@HOSTS)
      self.gendata('error', "Unable load hosts' configuration from #{@@HOSTS}")
      return false
    end
    @@HOSTDATA = YAML.load_file(@@HOSTS)
    # validate received configuration
    self.hosts_validate(@@HOSTDATA)
    # total hosts count
    @@TOTAL = @@HOSTDATA.size
    self.log("Loaded hosts' data from file #{@@HOSTS}, totally #{@@TOTAL} entries")
    true
  end

  ## Run check for chosen host
  def self.check(hostdata)
    host = hostdata['host']  # parameter 'host' is common for all check types
    case hostdata['type']
    when 'http'
      port = hostdata['port'] || 80     # 80 — default HTTP port
      Check.http(host, port)
    when 'https'
      port = hostdata['port'] || 443    # 443 — default HTTPS port
      Check.https(host, port)
    when 'ping'
      timeout = hostdata['iters'] || 5  # by default, we'll send 5 ICMP packets
      Check.ping(host, timeout)
    when 'port'
      port = hostdata['port']           # no any default value, how-ow
      Check.port(host, port)
    end
    # By default, all the checks returns "OK" if no errors, and some another information if check
    # failed.
    #
    # I don't want to pass Check class methods to meta-code section, because, possible, we need to
    # implement some check with more than 2 parameters. Or completely use another module for some
    # of them.
  end

  ## Main watching loop
  def self.watch!
    loop do
      # we don't need monitor. if lock-file is absent
      if !File.exist?(@@STATUSFILE)
        break
      end
      @@HOSTDATA.each do |host|
        # previous check timestamp
        lastcheck = host[1]['lastcheck'] || 0
        # get current timestamp
        now = Time.now.to_i
        # if the previous check has been before current time minus checking timeout for the host
        if now - lastcheck > host[1]['timeout']
          checked = self.check(host[1])  # check result
          # log event if host status has been changed
          self.log("UPDATE: #{host[0]}: #{checked}") if host[1]['status'] != checked
          host[1]['status'] = checked
          host[1]['lastcheck'] = now
        end
      end
      self.gendata('monitor', @@HOSTDATA)
      sleep(@@TIMEOUT)
    end
  end

  ## Remove activity lock-file
  def self.rmstatus!
    if File.exist?(@@STATUSFILE)
      FileUtils.rm(@@STATUSFILE)
    end
  end

  # public methods section
  public

  ## Start monitoring service
  def self.start!
    # remove lock-file if the previous session hasn't been ended correctly
    self.rmstatus!
    if self.config_load? and self.hosts_load?
      FileUtils.touch(@@STATUSFILE)
      self.log("Monitoring process started")
      self.watch!
    end
  end

  ## Stop monitoring service
  def self.stop!
    self.rmstatus!
    self.log("Monitoring process stopped")
  end

end
