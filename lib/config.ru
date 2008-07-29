require 'rubygems'
require 'sinatra'

Sinatra::Application.default_options.merge!(
  :run => false,
  :env => ENV['RACK_ENV']
)

require File.expand_path(File.dirname(__FILE__) + '/../bin/restful_captcha')

run Sinatra.application
