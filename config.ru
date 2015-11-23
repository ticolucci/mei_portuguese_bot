require 'bundler'
Bundler.require

$stdout.sync = true

require './mei_portuguese_bot'
run Sinatra::Application
