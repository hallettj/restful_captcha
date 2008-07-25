module RestfulCaptcha
  module Rails
    module ControllerPlugin
      
      def self.included(base)
        base.helper_method :captcha, :reset_captcha
        base.extend(ClassMethods)
        @@captcha_host ||= nil
        @@captcha_params ||= {}
      end

      module ClassMethods
        def set_captcha_host(host)
          RestfulCaptcha::Rails::Captcha.host = host
        end
      end
      
      private

      def captcha
        Captcha.find_by_identifier(session[:captcha])
      end

      def reset_captcha
        captcha = Captcha.find_by_attributes(@@captcha_params)
        session[:captcha] = captcha.identifier
      end

      def unset_captcha
        session[:captcha] = nil
      end

      def verify_captcha(answer)
        captcha = Captcha.find_by_identifier(session[:captcha])
        captcha.correct_answer?(answer)
      end

    end
  end
end
