# This is a server that provides access to Captcha images and that
# verifies answers to Captcha challenges.
# 
# Captchas can be requested by attributes such as text, color, and
# font properties.
#
# The server exposes a RESTful API that allows read-only access to
# Captchas and their attributes. It responds to URLs in four formats:
#
### /captcha
#
# Finds a captcha that matches the given parameters and returns its
# identifier in the response body. If no parameters are given,
# responds with an identifier for a captcha picked at random.
#
# The parameters that are used are:
# * +text+ - the text displayed in the captcha image; will be randomly generated if not specified
# * +width+, +height+ - dimensions of the image in pixels; defaults to 200x100
# * +color+, +background_color+ - accpeted color values are described at http://www.imagemagick.org/RMagick/doc/imusage.html#color_names
# * +background+ - used to specify a background texture instead of a solid color; overrides background color if specified; accepted values are described at http://www.imagemagick.org/RMagick/doc/imusage.html#builtin_formats
# * +font+, +font_family+, +font_style+, +font_weight+, +font_size+ - font properties; see http://www.imagemagick.org/RMagick/doc/draw.html#font for info
# * +stroke_width+ - width of the line that is drawn
# * +secret+ - a string to be hidden in the captcha. It will be returned to the client in the event a correct answer is submitted.
#
### /captcha/:identifier
#
# Given a captcha identifier, returns the same identifier in the
# response body with an OK status; or responds with a 'resource not
# found' error if the captcha cannot be found.
#
# This is useful for clients wanting to verify that an identifier is
# valid.
#
### /captcha/:identifier/image
#
# Given a captcha identifier, returns the captcha's image in PNG format.
#
### /captcha/:identifier/:answer
#
# Given a captcha identifier and a proposed answer, returns the
# validity of the answer. The response is in the format of a YAML
# file, where the validity of the answer is represented as a boolean
# with the key 'correct'.
#
# The response also includes the captcha identifier and the answer
# given, with the keys 'identifier' and 'answer' respectively.
#
# If the given answer is correct, the YAML response also includes the
# secret string embedded in the captcha, if there is one.

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'restful_captcha/image'
require 'restful_captcha/captcha'

module RestfulCaptcha
  VERSION = '1.0.0'
end
