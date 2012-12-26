require './allisdown.rb'
require './monitor.rb'

run Sinatra::Application

at_exit { Monitor.stop! }
