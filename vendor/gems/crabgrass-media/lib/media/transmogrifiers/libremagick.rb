module Media
  #
  # uses libreoffice and graphicsmagick transmogrifiers to convert from office documents to image documents,
  # by way of PDF.
  #

  class LibreMagickTransmogrifier < Media::Transmogrifier

    def self.libre
      Media::Transmogrifier.list["Media::LibreOfficeTransmogrifier"]
    end

    def self.magick
      Media::Transmogrifier.list["Media::GraphicsMagickTransmogrifier"]
    end

    def self.input_types
      libre.input_types
    end

    def self.output_types
      # we don't want to use this for pdf, since libreoffice by itself can generate pdf
      magick.output_types - ['application/pdf']
    end

    def self.available?
      libre &&
        magick &&
        libre.available? &&
        magick.available? &&
        ghostscript_available?
    end

    def self.ghostscript_available?
      cmd = `which ghostscript`.chomp
      !cmd.empty? && command_available?(cmd)
    end

    #
    # run libreoffice and then graphicsmagick in succession.
    #
    # all the options are passed to graphicsmagic, and none to libreoffice,
    # because they are probably not for libreoffice (like crop or resize).
    #
    def run(&block)
      pdf_output_file = Media::TempFile.new(nil, "application/pdf")
      libre_transmog = self.class.libre.new(
        input_file: input_file,       input_type: input_type,
        output_file: pdf_output_file, output_type: "application/pdf")
      status = libre_transmog.run(&block)
      return status if status != :success
      magick_transmog = self.class.magick.new(
        options.merge({
          input_file: pdf_output_file,  input_type: "application/pdf",
          output_file: output_file,     output_type: output_type
        })
      )
      magick_transmog.run(&block)
    end

  end
end
