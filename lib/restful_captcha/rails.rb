$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'net/http'
require 'uri'
require 'cgi'
require 'yaml'

require 'rails/captcha'
require 'rails/view_plugin'
require 'rails/controller_plugin'

module RestfulCaptcha

  # == Synopsis
  #
  # This module contains all of the Rails plugin code for client-side
  # RestfulCaptcha functionality. It inserts plugin methods into
  # ActionController::Base and ActionView::Base.
  #
  # Simply add this line to your controller to include the Rails
  # plugin in your application:
  #     require 'restful_captcha/rails'
  module Rails
  end
end

# ActionView::Base is extended by RestfulCaptcha::Rails. See
# RestfulCaptcha::Rails::ViewPlugin for details.
class ActionView::Base
  include RestfulCaptcha::Rails::ViewPlugin
end

# ActionController::Base is extended by RestfulCaptcha::Rails. See
# RestfulCaptcha::Rails::ViewPlugin for details.
class ActionController::Base
  include RestfulCaptcha::Rails::ControllerPlugin

  # Sets the style attributes for captchas that will appear in views
  # rendered by the calling controller. Style +options+ can be defined
  # differently in each controller class. Any style +options+ defined
  # in a parent controller class will be inhereted by its children
  # except options that are explicitly overridden in the child classes
  #
  # Valid options are:
  # * <tt>:text</tt> - the text displayed in the captcha image; will be randomly generated if not specified
  # * <tt>:width</tt>, <tt>:height</tt> - dimensions of the image in pixels; defaults to 200x100
  # * <tt>:color</tt>, <tt>:background_color</tt> - accpeted color values are described at http://www.imagemagick.org/RMagick/doc/imusage.html#color_names
  # * <tt>:background</tt> - used to specify a background texture instead of a solid color; overrides background color if specified; accepted values are described at http://www.imagemagick.org/RMagick/doc/imusage.html#builtin_formats
  # * <tt>:font</tt>, <tt>:font_family</tt>, <tt>:font_style</tt>, <tt>:font_weight</tt>, <tt>:font_size</tt> - font properties; see http://www.imagemagick.org/RMagick/doc/draw.html#font for info
  # * <tt>:stroke_width</tt> - width of the line that is drawn
  # * <tt>:secret</tt> - a string to be hidden in the captcha. It will be returned to the client in the event a correct answer is submitted.
  #
  # TODO: Find a way to move this into the definition for
  # ControllerPlugin
  def self.set_captcha_style(options)
    @@captcha_params ||= {}
    @@captcha_params.merge!(options)
  end
end
