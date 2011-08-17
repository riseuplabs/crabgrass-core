#
# transform image formats using the graphicsmagick command line executable "gm"
# requires "apt-get install graphicsmagick"
#

unless defined?(GRAPHICSMAGICK_COMMAND)
  GRAPHICSMAGICK_COMMAND = `which gm`.chomp
end

#
# this is a little bit brittle, but I am not sure how else to do it.
#
unless defined?(GRAPHICSMAGICK_VERSION)
   version = `#{GRAPHICSMAGICK_COMMAND} -version | head -1`.strip.sub(/GraphicsMagick ([0-9]+\.[0-9]+\.[0-9]+).*/,'\1').split('.')
   GRAPHICSMAGICK_VERSION = [version[0].to_i, version[1].to_i, version[2].to_i]
end

class GraphicsMagickTransmogrifier < Media::Transmogrifier

  def input_types
    %w( application/pdf application/bzpdf application/gzpdf
        application/postscript application/xpdf image/jpeg image/pjpeg image/gif
        image/png image/x-png image/jpg image/tiff )
  end

  #def input_types
  #  self.class.input_types
  #end

  def output_types
    %w( application/pdf image/jpeg image/pjpeg
        image/gif image/png image/jpg image/tiff )
  end

  def available?
    command_available?(GRAPHICSMAGICK_COMMAND)
  end

  #
  # gm has an option -monitor that will spit out the progress. 
  # this could be interesting. we would need to use getc instead of gets
  # on the pipe, since the progress is updated on a single line.
  #
  def run(&block)
    # +profile '*' will remove all the image profiles, which will save
    # space (sometimes) and are not useful for thumbnails
    arguments = [gm_command, 'convert', '+profile', "'*'"]
    if options[:size]
      # handle multiple size options, if it is an array.
      sizes = options[:size].is_a?(Array) ? options[:size] : [options[:size]]
      sizes.each do |size|
        if version_less_than?(1,3,6)
          size = size.sub('^','!')
        end
        arguments << '-geometry' << size
      end
    end
    if options[:crop]
      # we add '+0+0' because we don't want tiles, just a single image
      arguments << '-crop' << options[:crop]+'+0+0'
    end
    arguments << input_file << output_file
    run_command(*arguments, &block)
  end

  def dimensions(filename)
    if available?
      args = [gm_command, 'identify', '-format', '%m %w %h', filename]
      dimensions = nil
      status = run_command(*args) do |output|
         dimensions = output
      end
      if status == :success
        type, width, height = dimensions.split /\s/
        return [width,height]
      else
        return nil
      end
    end
  end

  # this override is just used for test, at the moment.
  def gm_command
    GRAPHICSMAGICK_COMMAND
  end

  def version_less_than?(major,minor,tiny)
    installed_major, installed_minor, installed_tiny = GRAPHICSMAGICK_VERSION
    if installed_major < major
      true
    elsif (installed_major == major) 
      if (installed_minor < minor)
        true
      elsif (installed_minor == minor) && (installed_tiny < tiny)
        true
      else
        false
      end
    else
      false
    end
  end

end

GraphicsMagickTransmogrifier.new

