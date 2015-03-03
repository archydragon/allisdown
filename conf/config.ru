require './src/allisdown.rb'
require './src/allisdown/monitor.rb'

run Sinatra::Application

at_exit { Monitor.stop! }
