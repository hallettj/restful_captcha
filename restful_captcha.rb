#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'sinatra'
require 'activesupport'
require 'yaml'

require 'lib/restful_captcha/image'
require 'lib/restful_captcha/captcha'

# Finds a captcha that matches the given parameters and returns its
# identifier in the response body. If no parameters are given,
# responds with an identifier for a captcha picked at random.
get '/captcha' do
  @captcha = RestfulCaptcha::Captcha.new(params)
  @captcha.identifier
end

# Given a captcha identifier, returns the same identifier in the
# response body with an OK status; or responds with a 'resource not
# found' error if the captcha cannot be found.
#
# This is useful for clients wanting to verify that an identifier is
# valid.
get '/captcha/:identifier' do
  @captcha = RestfulCaptcha::Captcha.find(params[:identifier])
  if @captcha.nil?
    throw :halt, [404, "Captcha not found"]
  end
  @captcha.identifier
end

# Given a captcha identifier, returns the captcha's image.
get '/captcha/:identifier/image' do
  @captcha = RestfulCaptcha::Captcha.find(params[:identifier])
  if @captcha.nil?
    throw :halt, [404, "Image not found"]
  end
  send_data(@captcha.image, :filename => 'captcha.png', :type => 'image/png', :disposition => 'inline')
end

get '/captcha/:identifier/:answer' do
  @captcha = RestfulCaptcha::Captcha.find(params[:identifier])

  if @captcha.nil?
    throw :halt, [404, "Captcha not found"]
  end

  response = { 
    "identifier" => params[:identifier],
    "answer" => params[:answer]
  }

  if @captcha.correct_answer?(params[:answer])
    response["correct"] = true
    response["secret"] = @captcha[:secret] unless @captcha[:secret].blank?
  else
    response["correct"] = false    
  end

  header 'Content-Type' => 'text/x-yaml; charset=utf-8'
  header 'Content-Disposition' => 'inline'
  response.to_yaml
end
