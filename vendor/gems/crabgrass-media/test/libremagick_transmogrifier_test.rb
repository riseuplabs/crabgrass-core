require 'test_helper'
require 'media/transmogrifiers/libremagick'

class LibreMagickTransmogrifierTest < Minitest::Test

  def test_libremagick_transmog
    skip 'dependencies missing' unless klass.available?
    input = file('msword.doc')
    transmog =
      klass.new input_file: input,
      output_type: 'image/jpg'
    status = transmog.run
    assert_equal :success, status
    assert File.exist?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /JPEG/),
      "output should be a jpg: #{file_info(transmog.output_file)}"
  end

  protected

  def klass
    Media::LibreMagickTransmogrifier
  end
end
