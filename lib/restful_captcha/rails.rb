$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'net/http'
require 'uri'
require 'cgi'
require 'yaml'

require 'rails/captcha'
require 'rails/view_plugin'
require 'rails/controller_plugin'

class ActionView::Base
  include RestfulCaptcha::Rails::ViewPlugin
end

class ActionController::Base
  include RestfulCaptcha::Rails::ControllerPlugin

  ## TODO: Find a way to move this into the definition for
  ## ControllerPlugin
  def self.set_captcha_style(options)
    @@captcha_params ||= {}
    @@captcha_params.merge!(options)
  end
end
