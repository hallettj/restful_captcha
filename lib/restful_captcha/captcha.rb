require 'activesupport'
require 'crypt/rijndael'

require File.expand_path(File.dirname(__FILE__) + '/../core_extensions.rb')

module RestfulCaptcha

  # == Synopsis
  #
  # RestfulCaptcha::Captcha represents a Captcha. It has text, image
  # properties, and image, and possibly a secret as attributes.
  #
  # Once a Captcha is created, its image can be accessed by calling
  # captcha.image
  class Captcha

    # A new Captcha accepts +options+ than define how its image will
    # appear. The options that are accepted are:
    # * +text+ - the text displayed in the captcha image; will be randomly generated if not specified
    # * +width+, +height+ - dimensions of the image in pixels; defaults to 200x100
    # * +color+, +background_color+ - accpeted color values are described at http://www.imagemagick.org/RMagick/doc/imusage.html#color_names
    # * +background+ - used to specify a background texture instead of a solid color; overrides background color if specified; accepted values are described at http://www.imagemagick.org/RMagick/doc/imusage.html#builtin_formats
    # * +font+, +font_family+, +font_style+, +font_weight+, +font_size+ - font properties; see http://www.imagemagick.org/RMagick/doc/draw.html#font for info
    # * +stroke_width+ - width of the line that is drawn
    # * +secret+ - a string to be hidden in the captcha. It will be returned to the client in the event a correct answer is submitted.

    def initialize(options={})
      options = options.symbolize_keys
      recipe = options.reject { |k,v| !(Image::VALID_OPTIONS.include?(k)) }
      recipe[:text] ||= random_string(5)
      @recipe = recipe
      @secret = options[:secret]
    end

    # Given a Captcha identifier, returns the corresponding captcha.
    #
    # Behind the scenes, the identifier is actually a YAML file
    # containing the properties of the desired captcha that has been
    # encrypted, compressed, and encoded in hexadecimal. This method
    # converts it back to binary, decompresses it, decrypts it, and
    # creates a new captcha with the properties listed in the
    # resulting YAML file.
    def self.find(identifier)
      recipe = YAML::load(decrypt(Zlib::Inflate.inflate(hex_to_bin(identifier))))
      Captcha.new(recipe)
    rescue
      nil
    end

    # Returns the captcha's identifier, which can be used to retrieve
    # the captcha later.
    #
    # Behind the scenes, the identifier is actually a YAML file
    # containing the properties of the desired captcha that has been
    # encrypted, compressed, and encoded in hexadecimal.
    def identifier
      identifier_params = @recipe.reject { |k,v| v.nil? }.stringify_keys
      identifier_params[:secret] = @secret unless @secret.blank?
      bin_to_hex(Zlib::Deflate.deflate(encrypt(identifier_params.to_yaml)))
    end

    # Returns the captcha image in PNG format. 
    #
    # RMagick is used to actually build the the image given the
    # captcha's attributes.
    def image
      Image.build(@recipe)
    end

    # Returns true if +answer+ matches the captcha's text, and false otherwise.
    #
    # By default the comparison between +answer+ and the captcha's
    # text is not case sensitive. Pass +true+ as the second argument
    # to make the check case sensitive.
    def correct_answer?(answer, case_sensitive=false)
      correct_answer = case_sensitive ? self[:text] : self[:text].downcase
      answer = answer.downcase unless case_sensitive
      !answer.blank? and correct_answer == answer
    end

    # Retrieves one of the captcha's attributes by name. +attribute+
    # should be a Symbol or a String.
    #
    # See RestfulCaptcha::Captcha#initialize for a list of attributes.
    def [](attribute)
      attribute.to_sym == :secret ? @secret : @recipe[attribute.to_sym]
    end

    # Sets one of the captchas attributes by name. +attribute+ should
    # be a Symbol or a String.
    #
    # See RestfulCaptcha::Captcha#initialize for a list of attributes.
    def []=(attribute, value)
      if attribute.to_sym == :secret
        @secret = value
      elsif Image::VALID_OPTIONS.include?(attribute.to_sym)
        @recipe[attribute.to_sym] = value
      else
        raise ArgumentError, "invalid attribute for RestfulCaptcha::Captcha: '#{value.inspect}'"
      end
    end

    # Returns true if the receiver and +other_captcha+ have identical
    # attributes, false otherwise.
    def ==(other_captcha)
      @recipe.each do |k,v|
        return false if other_captcha[k] != v
      end
      return (@secret == other_captcha[:secret])
    end
    
    private

    # Generates a random string containing upper- and lower-case
    # letters and numbers with the given +length+.
    def random_string(length=5)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      string = ""
      length.times { string << chars[rand(chars.size-1)] }
      return string
    end

    # Encrypts +message+ use the Rijndael implementation of AES. 
    #
    # The encryption key is read from the file, 'keyfile', which
    # should be placed in the top-level directory of the
    # application. This is a symmetric encryption algorithm; so the
    # same key is used for encryption and decryption.
    #
    # Encryption uses ECB for encrypting multiple blocks instead of
    # the more widely used CBC. Using ECB results in significantly
    # shorter encrypted strings when the input string is short, but at
    # the expense of somewhat weaker encryption.
    def encrypt(message)
      key = File.open('keyfile','r') { |f| f.read }
      block_length = key.length
      rijndael = Crypt::Rijndael.new(key)

      # split message into blocks with the same length as the encryption key
      blocks = Array.new((message.length.to_f / block_length.to_f).ceil).collect_with_index do |b,i|
        b = message[i*block_length..(i*block_length)+block_length-1]
      end

      # pad the last block with null characters to fill it out to
      # block_length bytes
      while blocks.last.length < block_length
        blocks.last << "\0"
      end

      blocks.collect { |b| rijndael.encrypt_block(b) }

      # return the blocks as a single string
      return blocks.join('')
    end

    class << self
      
      # Decrypts +message+ use the Rijndael implementation of AES. 
      #
      # The decryption key is read from the file, 'keyfile', which
      # should be placed in the top-level directory of the
      # application. This is a symmetric encryption algorithm; so the
      # same key is used for encryption and decryption.
      #
      # Encryption uses ECB for encrypting multiple blocks instead of
      # the more widely used CBC. Using ECB results in significantly
      # shorter encrypted strings when the input string is short, but
      # at the expense of somewhat weaker encryption.
      def decrypt(message)
        key = File.open('keyfile','r') { |f| f.read }
        block_length = key.length
        rijndael = Crypt::Rijndael.new(key)
        
        # split message into blocks with the same length as the encryption key
        blocks = Array.new((message.length.to_f / block_length.to_f).ceil).collect_with_index do |b,i|
          b = message[i*block_length..(i*block_length)+block_length-1]
        end
        
        blocks.collect { |b| rijndael.decrypt_block(b) }
        
        # remove any null character padding from the last block
        blocks.last.sub!(/\0+$/,'')

        # return the decrypted message
        return blocks.join('')
      end
      
    end

    # Encodes a string, possibly containing binary data, in
    # hexadacimal - which is a nice safe encoding for use in a URL.
    def bin_to_hex(bin)
      bin.unpack('H*').first
    end

    # Encodes a string, possibly containing binary data, in base64
    # encoding. This results in shorter encoded strings than
    # hexadecimal; but it has the disadvantages that encoded strings
    # often contain characters that are not safe for URL parameters,
    # and the encoded string is case sensitive.
    def base64_encode(bin)
      [bin].pack('m')
    end

    class << self

      # Converts a hexadecimal encoded string back to its original
      # representation - which can be binary.
      def hex_to_bin(hex)
        [hex].pack('H*')
      end
      
      # Converts a base64 encoded string back to its original
      # representation - which can be binary.
      def base64_decode(base64)
        base64.unpack('m').first
      end
      
    end

  end
end
