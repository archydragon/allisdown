#!/usr/bin/env ruby -wKU
# encoding: utf-8

# # # allisdown/allisdown.rb
# # # Web-interface for monitoring system, based on Sinatra
# # # Last updated: 2012-12-26, Mendor (for the details see changelog and git commit history)

require 'rubygems'
require 'sinatra'
require 'thin'
require 'erb'
require './monitor.rb'  # backend script

### A bit of backend

# we need to try to start monitoring process
Thread.new { 
  Monitor.start!
}

### HTTP methods for web-frontend

## Main page — current monitoring status
get '/' do
  @monconfig = 'conf/monitor.conf.yml'
  @is_error = false
  # check possible errors
  if !File.exist?(@monconfig)
    @error = "Unable load configuration file #{@monconfig}"
    @is_error = true
  else
    config = YAML.load_file(@monconfig)
    @frontend = config['frontend']
    if !File.exist?(@frontend)
      @error = "Unable load data file #{@frontend}"
      @is_error = true
    else
      @frontdata = YAML.load_file(@frontend)
      if @frontdata['error']
        @error = @frontdata['error']
        @is_error = true
      end
    end
  end
  # if @is_error still false, YAML with frontend data will be processed during view render
  erb :index
end

## Restart monitoring thread
# This links isn't mentioned in default view template for index page, insert it anywhere manually
# if you need
get '/restart' do
  Monitor.stop!
  Monitor.start!
  redirect to('/')
end
