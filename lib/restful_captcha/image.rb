require 'RMagick'
require 'activesupport'

module RestfulCaptcha

  # == Synopsis
  #
  # RestfulCaptcha::Image has a single public class method,
  # RestfulCaptcha::Image.build, which is used to build captcha images.
  class Image

    VALID_OPTIONS = [:text, 
                     :width, :height, 
                     :color, :background_color, :background, 
                     :font, :font_family, :font_style, :font_weight, :font_size,
                     :stroke_width]
    
    # Builds a captcha image according to the given +options+. The
    # Options that are accepted are defined by
    # RestfulCaptcha::Image::VALID_OPTIONS. Specifically, they are:
    # * +text+ - the text displayed in the captcha image; will be randomly generated if not specified
    # * +width+, +height+ - dimensions of the image in pixels; defaults to 200x100
    # * +color+, +background_color+ - accpeted color values are described at http://www.imagemagick.org/RMagick/doc/imusage.html#color_names
    # * +background+ - used to specify a background texture instead of a solid color; overrides background color if specified; accepted values are described at http://www.imagemagick.org/RMagick/doc/imusage.html#builtin_formats
    # * +font+, +font_family+, +font_style+, +font_weight+, +font_size+ - font properties; see http://www.imagemagick.org/RMagick/doc/draw.html#font for info
    # * +stroke_width+ - width of the line that is drawn

    def self.build(options)
      options.symbolize_keys!
      options.assert_valid_keys(VALID_OPTIONS)

      text = options[:text]
      if text.blank?
        raise ArgumentError, "cannot generate a CAPTCHA image without text to display"
      end

      width = options[:width] ? options[:width].to_i : 200
      height = options[:height] ? options[:height].to_i : 100
      color = options[:color] || 'black'

      # Set the background texture or color
      unless options[:background].blank?
        background = options[:background]
        background_texture = Magick::ImageList.new("#{background}:")
        canvas = Magick::ImageList.new
        canvas.new_image(width, height, Magick::TextureFill.new(background_texture))
      else
        background_color = options[:background_color] || 'white'
        canvas = Magick::ImageList.new
        canvas.new_image(width, height) { self.background_color = background_color }
      end
      
      font_family = options[:font_family] || 'helvetica'

      ## Draw text
      draw = Magick::Draw.new
      draw.font_family = font_family
      draw.pointsize = 52
      draw.font_stretch = Magick::UltraCondensedStretch
      draw.gravity = Magick::CenterGravity
      draw.annotate(canvas, 0,0,0,0, text) {
        self.fill = color
      }

      canvas = draw_angled_line(canvas, :width => width, :height => height, :color => color)

      min_swirl = 30.0
      max_swirl = 50.0
      swirl_sign = rand(100) < 50 ? -1 : 1
      canvas = canvas.swirl(swirl_sign * (rand(max_swirl - min_swirl) + min_swirl))

      canvas.format = 'PNG'
      return canvas.to_blob
    end

    protected

    # Draws a wiggly line across the given +image+. This makes it
    # difficult for a CAPTCHA breaking bot to identify individual
    # letters.
    #
    # Required options are:
    # * +width+ - width of +image+ in pixels
    # * +height+ - height of +image+ in pixels
    #
    # Optional options are:
    # * +color+ - color of the line that is drawn
    # * +stroke_width+ - width of the line that is drawn
    def self.draw_angled_line(image, options)
      width = options[:width]
      height = options[:height]
      color = options[:color] || black
      stroke_width = options[:stroke_width] || 3

      height_variance = height * 0.10
      segment_length = 10.0
      num_segments = (width / segment_length) - 2
      segment_height_variance = (height_variance / num_segments) * 3.0

      left_end = [segment_length, (height / 2.0) + rand(height_variance * 2.0) - height_variance]
      right_end = [width - segment_length,
                   (height / 2.0) + rand(height_variance * 2.0) - height_variance]
      midpoint = [(rand(num_segments - 2) + 2) * segment_length,
                  (height / 2.0) + rand(height_variance) - height_variance]

      polyline_path = []

      # Define line segments from left_end to midpoint
      last_x = left_end[0]
      last_y = left_end[1]
      Array.new((midpoint[0] - left_end[0]) / segment_length).each_with_index do |e,i|
        x = (i + 1) * segment_length
        y = last_y + (1 / ((midpoint[0] - last_x) / segment_length)) * (midpoint[1] - last_y) +
          rand(segment_height_variance * 2.0) - segment_height_variance
        last_x = x
        last_y = y
        polyline_path << [x,y]
      end

      # Define line segments from midpoint to right_end
      last_x = midpoint[0]
      last_y = midpoint[1]
      Array.new((right_end[0] - midpoint[0]) / segment_length).each_with_index do |e,i|
        x = midpoint[0] + ((i + 1) * segment_length)
        y = last_y + (1 / ((right_end[0] - last_x) / segment_length)) * (right_end[1] - last_y) +
          rand(segment_height_variance * 2.0) - segment_height_variance
        last_x = x
        last_y = y
        polyline_path << [x,y]
      end

      polyline_path.flatten!
      
      draw = Magick::Draw.new
      draw.stroke(color)
      draw.fill_opacity(0)
      draw.stroke_width(3)
      draw.stroke_linecap('round')
      draw.stroke_linejoin('round')

      draw.polyline(*polyline_path)
      draw.draw(image)

      return image
    end

    ## Old version
#     def draw_angled_line(image)
#           height_variance = height * 0.06
#           segment_length = 10.0
#           num_segments = (width / segment_length) - 2
#           segment_height_variance = (height_variance / num_segments) * 12.0
#           bias = rand((segment_height_variance / num_segments) * 0.125) - 
#             (segment_height_variance / num_segments) * 0.0625

#           index = 0
#           last_y = (height / 2) + rand(height_variance * 2.0) - (height_variance)

#           polyline_path = Array.new(num_segments).collect { |p|
#             index += 1
      
#             x = index * segment_length
#             y = last_y + rand(segment_height_variance * 2.0) - segment_height_variance + bias

#             last_y = y
      
#             [x, y]
#           }.flatten
#     end

  end
end
