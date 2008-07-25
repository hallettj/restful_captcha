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

#         def self.set_captcha_style(options)
#           if class_variable_defined(:@@captcha_params)
#             existing_params = class_variable_get(:@@captcha_params)
#           else
#             existing_params = {}
#           end
#           class_variable_set(:@@captcha_params, existing_params.merge(options))
#         end
        
      end
      
      private

      def captcha
        Captcha.find_by_identifier(session[:captcha])
      end

      def reset_captcha
        captcha = Captcha.find_by_attributes(@@captcha_params)
        session[:captcha] = captcha.identifier
        return captcha
      end

      def unset_captcha
        session[:captcha] = nil
      end

    end
  end
end
