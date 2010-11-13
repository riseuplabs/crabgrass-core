
module Media::Process
  class GraphicMagick < Processor

    cattr_accessor :gm_override

    def to_sym; :graphic_magick; end

    def available?
      GM_COMMAND.any? and File.exists?(GM_COMMAND)
    end

    def run(options)
      # +profile '*' will remove all the image profiles, which will save
      # space (sometimes) and are not useful for thumbnails
      arguments = [GM_COMMAND, 'convert', '+profile', "'*'"]
      if options[:size]
        arguments << '-geometry' << options[:size]
      end
      if options[:crop]
        arguments << '-crop' << options[:crop]+'+0+0'
        # (we add '+0+0' because we don't want tiles, just a single image)
      end
      arguments << options[:in].to_s << options[:out].to_s
      success, output = cmd(*arguments)
      return success
    end

    def dimensions(filename)
      if GM_COMMAND.any?
        args = [self.gm_override||GM_COMMAND, 'identify', '-format', '%m %w %h', filename]
        success, dimensions = cmd(*args)
        if success
          type, width, height = dimensions.split /\s/
          return [width,height]
        end
      end
    end

  end
end

