$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'restful_captcha/image'
require 'restful_captcha/captcha'

module RestfulCaptcha
  VERSION = '1.0.0'
end
