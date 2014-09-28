#
# uses libreoffice and graphicsmagick transmogrifiers to convert from office documents to image documents,
# by way of PDF.
#

class LibreMagickTransmogrifier < Media::Transmogrifier

  def libre
    Media::Transmogrifier.list["LibreOfficeTransmogrifier"]
  end

  def magick
    Media::Transmogrifier.list["GraphicsMagickTransmogrifier"]
  end

  def input_types
    libre.input_types
  end

  def output_types
    # we don't want to use this for pdf, since libreoffice by itself can generate pdf
    magick.output_types - ['application/pdf']
  end

  def available?
    libre and magick and libre.available? and magick.available?
  end

  #
  # run libreoffice and then graphicsmagick in succession.
  #
  # all the options are passed to graphicsmagic, and none to libreoffice,
  # because they are probably not for libreoffice (like crop or resize).
  #
  def run(&block)
    pdf_output_file = Media::TempFile.new(nil, "application/pdf")
    libre_transmog = libre.class.new(
      input_file: input_file,       input_type: input_type,
      output_file: pdf_output_file, output_type: "application/pdf")
    status = libre_transmog.run(&block)
    return status if status != :success
    magick_transmog = magick.class.new(
      options.merge({
        input_file: pdf_output_file,  input_type: "application/pdf",
        output_file: output_file,     output_type: output_type
      })
    )
    magick_transmog.run(&block)
  end

end

LibreMagickTransmogrifier.new
