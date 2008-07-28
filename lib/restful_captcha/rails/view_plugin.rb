module RestfulCaptcha
  module Rails
    
    # == Synopsis
    # 
    # The methods in this module are available to use anywhere in
    # template code.
    #
    # RestfulCaptcha::Rails::ControllerPlugin also defines some
    # helpers that are available in template code.
    module ViewPlugin

      # Returns an HTML image tag with an href pointing to the image
      # url of the captcha associated with the current user. This
      # method calls ActionController::Base#reset_captcha; so a
      # different captcha is shown every time this method is called.
      #
      # The optional +options+ hash is passed to the image_tag method,
      # which is used to generate the HTML tag for the displayed image.
      def captcha_tag(options={})
        reset_captcha
        image_tag(captcha.image_url, options.reverse_merge(:alt => 'captcha image'))
      end    

    end
  end
end
