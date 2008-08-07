# == Synopsis
#
# RestfulCaptcha::Rails::Captcha represents a captcha. It actually
# acts as a proxy by translating method calls into HTTP requests which
# are sent to a RestfulCaptcha server.

module RestfulCaptcha
  module Rails

    class Captcha
      @@host = nil

      class ServerError < StandardError

      end

      attr_reader :identifier, :answer

      def initialize(identifier)  # :nodoc:
        @identifier = identifier
      end

      # Returns a captcha that has the attributes specified by
      # +options+. If no +options+ are present, a random captcha is
      # returned.
      def self.find_by_attributes(options={})
        path = "/captcha?#{options.map { |k,v| "#{k}=#{v}" }.join('&') }"
        begin
          res = Net::HTTP.start(server_url.host, server_url.port) do |http|
            http.get(path)
          end
        rescue => err
          raise ServerError, "#{err.class.name}: #{err.message}"
        end
        case res
        when Net::HTTPSuccess
          return new(res.body)
        when Net::HTTPNotFound
          return nil
        else
          raise ServerError, res.message 
        end
      end

      # Returns the captcha identified by +identifier+. If there is no
      # such captcha, returns +nil+.
      def self.find_by_identifier(identifier)
        return nil if identifier.blank?
        begin
          res = Net::HTTP.start(server_url.host, server_url.port) do |http|
            http.get("/captcha/#{identifier}")
          end
        rescue => err
          raise ServerError, "#{err.class.name}: #{err.message}"
        end
        case res
        when Net::HTTPSuccess
          return new(identifier)
        when Net::HTTPNotFound
          return nil 
        else
          raise ServerError, res.message
        end
      end

      # Sets the HTTP host of the RestfulCaptcha server that
      # RestfulCaptcha::Rails::Captcha and its instances access to
      # +host+.
      def self.host=(host)
        @@host = host
      end

      # Returns the URL of the image for this captcha on the
      # RestfulCaptcha server.
      def image_url
        captcha_url + '/image'
      end

      # Specifies +new_answer+ as the answer to the captcha challenge
      # given by the user. Setting this causes a call to
      # RestfulCaptcha::Rails::Captcha#correct_answer? to check
      # whether +new_answer+ is correct.
      #
      # You can change the answer by calling this method at any time
      # with a different
      # value. RestfulCaptcha::Rails::Captcha#correct_answer? will
      # check the last answer supplied by this method.
      def answer=(new_answer)
        return @answer if @answer == new_answer
        path = captcha_url + "/#{CGI::escape(new_answer)}"
        res = Net::HTTP.start(server_url.host, server_url.port) do |http|
          http.get(path)
        end
        decision = YAML::load(res.body)
        @answer = new_answer
        @answer_validity = decision['correct']
        return @answer
      end

      # This method is a shortcut for
      # RestfulCaptcha::Rails::Captcha#answer= and
      # RestfulCaptcha::Rails::Captcha#answered_correctly?. It sets
      # the proposed answer and checks its validity in a single call.
      #
      # This method caches the answer determination using the same
      # mechanism that answered_correctly? does; so successive calls
      # to this method or to answered_correctly? will not generate
      # additional HTTP requests unless +proposed_answer+ changes.
      def correct_answer?(proposed_answer)
        self.answer = proposed_answer
        answered_correctly?
      end

      # Returns true if the last answer set by
      # RestfulCaptcha::Rails::Captcha#answer= is correct, false
      # otherwise.
      #
      # The answer is checked by making a request to the
      # RestfulCaptcha server. But the determination is cached, so
      # successive calls to this method will not generate additional
      # HTTP requests unless the proposed answer is changed.
      def answered_correctly?
        @answer_validity
      end
      
      protected

      # Returns the base URL of this captcha on the RestfulCaptcha
      # server
      def captcha_url
        "http://#{host}/captcha/#{identifier}"
      end

      # Returns the currently specified host of a RestfulCaptcha server
      def host
        self.class.host
      end

      # Returns the full URL of the RestfulCaptcha server identified
      # by RestfulCaptcha::Rails::Captcha.host
      def server_url; self.class.server_url; end

      class << self

        # Returns the full URL of the RestfulCaptcha server identified
        # by RestfulCaptcha::Rails::Captcha.host
        def server_url
          URI.parse("http://#{host}/")
        end

        # Returns the currently specified host of a RestfulCaptcha server
        def host
          if @@host.blank?
            raise "No RestfulCaptcha host is specified. Please add a line to your controller like: set_captcha_host 'restfulcaptcha.com'"
          end
          @@host
        end

        protected :new

      end

    end

  end
end

