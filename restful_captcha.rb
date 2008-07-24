#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'rubygems'
require 'sinatra'
require 'activesupport'
require 'yaml'

require 'lib/restful_captcha/image'
require 'lib/restful_captcha/captcha'

get '/captcha' do
  @captcha = RestfulCaptcha::Captcha.new(params)
  @captcha.identifier
end

get '/image/:identifier' do
  @captcha = RestfulCaptcha::Captcha.load(params[:identifier])
  send_data(@captcha.image, :filename => 'captcha.png', :type => 'image/png', :disposition => 'inline')
end

get '/captcha/:identifier/:answer' do
  @captcha = RestfulCaptcha::Captcha.load(params[:identifier])

  response = { 
    "identifier" => CGI::escape(params[:identifier]),
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
