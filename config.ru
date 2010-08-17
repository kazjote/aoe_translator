require 'controller'

set :environment, (ENV['RACK_ENV'] || :production).to_sym
set :app_file, 'controller.rb'
disable :run

log = File.new('logs/sinatra.log', 'a')
STDOUT.reopen(log)
STDERR.reopen(log)

run Sinatra::Application

