require 'activesupport'
require 'crypt/rijndael'

require File.expand_path(File.dirname(__FILE__) + '/../core_extensions.rb')

module RestfulCaptcha
  class Captcha

    def initialize(options={})
      options = options.symbolize_keys
      recipe = options.reject { |k,v| !(Image::VALID_OPTIONS.include?(k)) }
      recipe[:text] ||= random_string(5)
      @recipe = recipe
      @secret = options[:secret]
    end

    def self.find(identifier)
      recipe = YAML::load(decrypt(Zlib::Inflate.inflate(hex_to_bin(identifier))))
      Captcha.new(recipe)
    rescue
      nil
    end

    def identifier
      identifier_params = @recipe.reject { |k,v| v.nil? }.stringify_keys
      identifier_params[:secret] = @secret unless @secret.blank?
      bin_to_hex(Zlib::Deflate.deflate(encrypt(identifier_params.to_yaml)))
    end

    def image
      Image.build(@recipe)
    end

    def correct_answer?(answer, case_sensitive=false)
      correct_answer = case_sensitive ? self[:text] : self[:text].downcase
      answer = answer.downcase unless case_sensitive
      !answer.blank? and correct_answer == answer
    end

    def [](attribute)
      attribute.to_sym == :secret ? @secret : @recipe[attribute.to_sym]
    end

    def []=(attribute, value)
      if attribute.to_sym == :secret
        @secret = value
      elsif Image::VALID_OPTIONS.include?(attribute.to_sym)
        @recipe[attribute.to_sym] = value
      else
        raise ArgumentError, "invalid attribute for RestfulCaptcha::Captcha: '#{value.inspect}'"
      end
    end

    def ==(other_captcha)
      @recipe.each do |k,v|
        return false if other_captcha[k] != v
      end
      return (@secret == other_captcha[:secret])
    end
    
    private

    def random_string(length=5)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      string = ""
      length.times { string << chars[rand(chars.size-1)] }
      return string
    end

    def encrypt(message)
      key = File.open('keyfile','r') { |f| f.read }
      rijndael = Crypt::Rijndael.new(key)

      # split message into 16 byte blocks
      blocks = Array.new((message.length / 16.0).ceil).collect_with_index do |b,i|
        b = message[i*16..i*16+15]
      end

      # pad the last block with null characters to fill it out to 16
      # bytes
      while blocks.last.length < 16
        blocks.last << "\0"
      end

      blocks.collect { |b| rijndael.encrypt_block(b) }

      # return the blocks as a single string
      return blocks.join('')
    end

    class << self
      
      def decrypt(message)
        key = File.open('keyfile','r') { |f| f.read }
        rijndael = Crypt::Rijndael.new(key)
        
        # split message into 16 byte blocks
        blocks = Array.new((message.length / 16.0).ceil).collect_with_index do |b,i|
          b = message[i*16..i*16+15]
        end
        
        blocks.collect { |b| rijndael.decrypt_block(b) }
        
        # remove any null character padding from the last block
        blocks.last.sub!(/\0+$/,'')

        # return the decrypted message
        return blocks.join('')
      end
      
    end

    def bin_to_hex(bin)
      bin.unpack('H*').first
    end

    def base64_encode(bin)
      [bin].pack('m')
    end

    class << self

      def hex_to_bin(hex)
        [hex].pack('H*')
      end
      
      def base64_decode(base64)
        base64.unpack('m').first
      end
      
    end

  end
end
