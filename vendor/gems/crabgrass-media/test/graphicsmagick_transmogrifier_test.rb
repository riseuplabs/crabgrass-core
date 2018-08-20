require 'test_helper'
require 'media/transmogrifiers/graphicsmagick'

class GraphicsMagickTransmogrifierTest < Minitest::Test

  def test_scaling_png_to_jpg
    input = file('lyra.png')
    transmog = Media::GraphicsMagickTransmogrifier.new input_file: input,
      output_type: 'image/jpg',
      size: '100x100!'
    assert transmog
    status = transmog.run
    assert_equal :success, status
    assert File.exist?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /JPEG/),
      "output should be a jpg: #{file_info(transmog.output_file)}"
    assert_equal ['100','100'], Media.dimensions(transmog.output_file),
      "output should be resized: #{file_info(transmog.output_file)}"
  end

  # libremagic transmogrifier uses this internally.
  def test_pdf_as_input
    skip('ghostscript required') if ghostscript_missing?
    input = file('kaos.pdf')
    transmog = Media::GraphicsMagickTransmogrifier.new input_file: input,
      output_type: 'image/jpg'
    status = transmog.run
    assert_equal :success, status
    assert File.exist?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /JPEG/),
      "output should be a jpg: #{file_info(transmog.output_file)}"
  end

  def ghostscript_missing?
    `which ghostscript`.empty?
  end

end
