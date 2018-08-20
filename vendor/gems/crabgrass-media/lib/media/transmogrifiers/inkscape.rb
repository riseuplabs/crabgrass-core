module Media
  unless defined?(INKSCAPE_COMMAND)
    INKSCAPE_COMMAND = `which inkscape`.chomp
  end

  class InkscapeTransmogrifier < Media::Transmogrifier

    def self.magick
      Media::Transmogrifier.list["Media::GraphicsMagickTransmogrifier"]
    end

    def self.output_types
      magick.output_types
    end

    def self.input_types
      %w(image/svg+xml image/svg+xml-compressed application/illustrator image/bzeps image/eps image/gzeps)
    end

    def self.available?
      command_available?(INKSCAPE_COMMAND) and magick and magick.available?
    end

    def run(&block)
      if output_type == 'image/png' and options.empty?
        arguments = [INKSCAPE_COMMAND, '--without-gui', '--export-area-drawing', '--export-area-snap', input_file, '--export-png', output_file]
        run_command(*arguments, &block)
      else
        png_output_file = Media::TempFile.new(nil, "image/png")
        arguments = [INKSCAPE_COMMAND, '--without-gui', '--export-area-drawing', '--export-area-snap', input_file, '--export-png', png_output_file]
        status = run_command(*arguments, &block)
        return status if status != :success
        magick_transmog = self.class.magick.new(
          options.merge({
            input_file: png_output_file,  input_type: "image/png",
            output_file: output_file,     output_type: output_type
          })
        )
        magick_transmog.run(&block)
      end
    end
  end
end
