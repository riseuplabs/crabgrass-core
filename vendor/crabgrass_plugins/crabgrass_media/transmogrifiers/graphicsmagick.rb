#
# transform image formats using the graphicsmagick command line executable "gm"
# requires "apt-get install graphicsmagick"
#

unless defined?(GRAPHICSMAGICK_COMMAND)
  GRAPHICSMAGICK_COMMAND = `which gm`.chomp
end

class GraphicsMagickTransmogrifier < Media::Transmogrifier

  def input_types
    %w( application/pdf application/bzpdf application/gzpdf
        application/postscript application/xpdf image/jpeg image/pjpeg image/gif
        image/png image/x-png image/jpg image/tiff )
  end

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
    arguments = [GRAPHICSMAGICK_COMMAND, 'convert', '+profile', "'*'"]
    if options[:size]
      arguments << '-geometry' << options[:size]
    end
    if options[:crop]
      # we add '+0+0' because we don't want tiles, just a single image
      arguments << '-crop' << options[:crop]+'+0+0'
    end
    arguments << input_file << output_file
    run_command(*arguments, &block)
  end

  def dimensions(filename)
    if available.any?
      args = [GRAPHICSMAGICK_COMMAND, 'identify', '-format', '%m %w %h', filename]
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

end

GraphicsMagickTransmogrifier.new

