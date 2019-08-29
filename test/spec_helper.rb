ENV['RACK_ENV'] = 'test'
require_relative '../app'
require_relative '../loan'
require 'rspec'
require 'rack/test'
require 'json'

Time.zone = 'Europe/Stockholm'

