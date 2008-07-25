module RestfulCaptcha
  module Rails
    module ViewPlugin
      def captcha_tag(options={})
        reset_captcha
        image_tag(captcha.image_url, options.reverse_merge(:alt => 'captcha image'))
      end    
    end
  end
end
