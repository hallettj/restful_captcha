require File.expand_path(File.dirname(__FILE__) + '/../bin/restful_captcha')
require 'spec'
require 'spec/interop/test'
require 'sinatra/test/methods'

include Sinatra::Test::Methods

Sinatra::Application.default_options.merge!(
  :env => :test,
  :run => false,
  :raise_errors => true,
  :logging => false
)

Sinatra.application.options = nil
