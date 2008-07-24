$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'net/http'
require 'uri'
require 'yaml'

module RestfulCaptcha
  module Plugin

    CAPTCHA_HOST = "localhost:4567"

    def self.included(base)
      base.helper_method :captcha_image_url
    end

    def reset_captcha
      url = URI.parse("http://#{CAPTCHA_HOST}/")
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.get('/captcha?color=darkblue&background_color=yellow&font_family=times&font_weight=bold')
      end
      captcha = res.body
      session[:captcha] = captcha
    end

    def captcha_image_url
      captcha = session[:captcha]
      if captcha.blank?
        raise "No CAPTCHA has been set in session data; call `reset_captcha` first"
      end
      url = "http://#{CAPTCHA_HOST}/image/#{captcha}"
      return url
    end

    def verify_captcha(answer)
      captcha = session[:captcha]
      if captcha.blank?
        raise "No CAPTCHA has been set in session data; call `reset_captcha` first"
      end
      url = URI.parse("http://#{CAPTCHA_HOST}/")
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.get("/captcha/#{captcha}/#{answer}")
      end
      response = YAML::load(res.body)
      return response['correct']
    end

  end
end
