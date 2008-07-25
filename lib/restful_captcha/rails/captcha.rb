module RestfulCaptcha
  module Rails

    class Captcha
      @@host = nil

      attr_reader :identifier, :answer

      def initialize(identifier)
        @identifier = identifier
      end

      def self.find_by_attributes(options={})
        path = "/captcha?#{options.map { |k,v| "#{k}=#{v}" }.join('&') }"
        res = Net::HTTP.start(server_url.host, server_url.port) do |http|
          http.get(path)
        end
        case res
        when Net::HTTPSuccess
          return new(res.body)
        else
          return nil
        end
      end

      def self.find_by_identifier(identifier)
        return nil if identifier.blank?
        res = Net::HTTP.start(server_url.host, server_url.port) do |http|
          http.get("/captcha/#{identifier}")
        end
        case res
        when Net::HTTPSuccess
          return new(identifier)
        else
          return nil
        end
      end

      def self.host=(host)
        @@host = host
      end

      def image_url
        "http://#{host}/image/#{@identifier}"
      end

      def answer=(new_answer)
        return @answer if @answer == new_answer
        path = "/captcha/#{@identifier}/#{CGI::escape(new_answer)}"
        res = Net::HTTP.start(server_url.host, server_url.port) do |http|
          http.get(path)
        end
        decision = YAML::load(res.body)
        @answer = new_answer
        @answer_validity = decision['correct']
        return @answer
      end

      def correct_answer?(proposed_answer)
        self.answer = proposed_answer
        answered_correctly?
      end

      def answered_correctly?
        @answer_validity
      end
      
      protected

      def host
        self.class.host
      end

      def server_url; self.class.server_url; end

      class << self

        def server_url
          URI.parse("http://#{host}/")
        end


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

