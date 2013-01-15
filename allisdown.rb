#!/usr/bin/env ruby -wKU
# encoding: utf-8

# # # allisdown/allisdown.rb
# # # Web-interface for monitoring system, based on Sinatra
# # # Last updated: 2012-12-26, Mendor (for the details see changelog and git commit history)

require 'rubygems'
require 'sinatra'
require 'thin'
require 'erb'
require 'active_support/core_ext/hash/conversions'
require './monitor.rb'  # backend script

### A bit of backend

# we need to try to start monitoring process
Thread.new { 
  Monitor.start!
}

### Helpers for frontend
helpers do

  # check configuration and frontend data availability
  def readfrontend(configfile)
    @error = ""
    if !File.exist?(configfile)
      @error = "Unable load configuration file #{configfile}"
    else
      config = YAML.load_file(configfile)
      @frontend = config['frontend']
      if !File.exist?(@frontend)
        @error = "Unable load data file #{@frontend}"
      end
    end
    @error
  end

end

### HTTP methods for web-frontend

## Main page — current monitoring status
get '/' do
  @monconfig = 'conf/monitor.conf.yml'
  @is_error = false
  @check = readfrontend(@monconfig)
  if (@check.length == 0)
    @frontdata = YAML.load_file(@frontend)
    if @frontdata['error']
      @error = @frontdata['error']
      @is_error = true
    end
  else
    @is_error = true
    @error = @check
  end
  # if @is_error still false, YAML with frontend data will be processed during view render
  erb :index
end

## XML output
get '/xml' do
  @monconfig = 'conf/monitor.conf.yml'
  @check = readfrontend(@monconfig)
  if (@check.length == 0)
    @frontdata = YAML.load_file(@frontend)
  else
    @frontdata = {'error' => @check}
  end
  @xml = @frontdata.to_xml(:skip_instruct => false, :root => 'allisdown')
  content_type 'text/xml'
  "#{@xml}"
end

## Restart monitoring thread
# This links isn't mentioned in default view template for index page, insert it anywhere manually
# if you need
get '/restart' do
  Monitor.stop!
  Monitor.start!
  redirect to('/')
end
