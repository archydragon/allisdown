require './src/allisdown.rb'
require './src/allisdown/monitor.rb'

Thread.new { Monitor.start! }

run Sinatra::Application

at_exit { Monitor.stop! }
