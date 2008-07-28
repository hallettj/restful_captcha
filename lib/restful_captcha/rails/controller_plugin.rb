# == Synopsis
#
# Extends ActionController::Base with methods for retrieving captchas
# and specifying attributes of the captchas to retrieve.

module RestfulCaptcha
  module Rails
    module ControllerPlugin
      
      def self.included(base)  # :nodoc:
        base.helper_method :captcha, :reset_captcha
        base.extend(ClassMethods)
        @@captcha_host ||= nil
        @@captcha_params ||= {}
      end

      module ClassMethods

        # Gives RestfulCaptcha::Rails::Captcha a host to use as a
        # RestfulCaptcha server. RestfulCaptcha::Rails::Captcha
        # methods will generally not function until a host is set.
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

      # Returns the captcha associated with the current user. A new
      # captcha can be associated with the user by calling
      # ActionController::Base#reset_captcha
      def captcha
        @captcha ||= Captcha.find_by_identifier(session[:captcha])
      end

      # Associates a new captcha with the current user. This is useful
      # if the user has already answered, or attempted to answer, a
      # previously associated captcha; or if no captcha has been
      # associated with the user yet.
      def reset_captcha
        @captcha = Captcha.find_by_attributes(@@captcha_params)
        session[:captcha] = @captcha.identifier
        return @captcha
      end

      # Removes any captcha associated with the current user. Calls to
      # ActionController::Base#captcha made after this will return nil
      # until ActionController::Base#reset_captcha is called.
      def unset_captcha
        session[:captcha] = nil
        @captcha = nil
      end

    end
  end
end
