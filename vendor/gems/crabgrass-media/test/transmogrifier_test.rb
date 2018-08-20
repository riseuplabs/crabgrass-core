require 'test_helper'
require 'media'
require_relative 'sleepy_transmogrifier'

class TransmogrifierTest < Minitest::Test

  def test_run_sleepy_transmog
    progress_strings = [
      'starting up.',
      'getting ready to do some work.',
      'working hard.',
      'winding down.',
      'that was tough.',
      'all done now.'
    ]
    transmog = SleepyTransmogrifier.new
    i = 0
    status = transmog.run do |progress|
      assert_equal progress_strings[i], progress
      putc ':'; STDOUT.flush
      i+=1
    end
    assert_equal :success, status
  end

  def test_transmog_not_found
    input = file('lyra.png')
    transmog = Media.transmogrifier input_file: input,
      output_type: 'image/xcf'
    assert_nil transmog
  end

  def test_graphicsmagick_transmog
    input = file('lyra.png')
    transmog = Media.transmogrifier(input_file: input, output_type: 'image/jpg', size: '100x100!')
    assert transmog
    status = transmog.run
    assert_equal :success, status
    assert File.exist?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /JPEG/),
      "output should be a jpg: #{file_info(transmog.output_file)}"
    assert_equal ['100','100'], Media.dimensions(transmog.output_file),
      "output should be resized: #{file_info(transmog.output_file)}"
  end

  def test_with_output_file
    input = file('lyra.png')
    Media::TempFile.open(nil,'image/jpg') do |dest_file|
      transmog = Media.transmogrifier(input_file: input, output_file: dest_file)
      assert transmog, 'should find transmog'
      status = transmog.run
      assert_equal :success, status
      assert File.exist?(dest_file.to_s)
      assert file_info_matches?(dest_file, /JPEG/), "output should be a jpg: #{file_info(transmog.output_file)}"
    end
  end

  def test_libreoffice_transmog
    input = file('msword.doc')
    transmog = Media.transmogrifier(input_file: input, output_type: 'application/pdf')
    assert transmog
    status = transmog.run
    assert_equal :success, status
    assert File.exist?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /PDF/), "output should be a pdf: #{file_info(transmog.output_file)}"
  end

  def test_doc_to_jpg_twostep_transmog
    skip "We're currently not exposing transformations from pdf. So this has to be done in one step"
    input = file('msword.doc')
    transmog = Media.transmogrifier(input_file: input, output_type: 'application/pdf')
    transmog.run

    transmog = Media.transmogrifier(input_file: transmog.output_file, output_type: 'image/jpg')
    status = transmog.run
    assert_equal :success, status
    assert File.exist?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /JPEG/), "output should be a jpg: #{file_info(transmog.output_file)}"
  end

  def test_no_pdf_transmog
    input = file('kaos.pdf')
    transmog = Media.transmogrifier(input_file: input, output_type: 'image/jpg')
    assert_nil transmog
  end

  def test_libremagick_transmog
    input = file('msword.doc')
    transmog = Media.transmogrifier(input_file: input, output_type: 'image/jpg')
    skip('libremagic is not available') unless transmog
    status = transmog.run
    assert_equal :success, status
    assert File.exist?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /JPEG/), "output should be a jpg: #{file_info(transmog.output_file)}"
  end

  def test_inkscape_transmog
    input = file('anarchism.svg')
    transmog = Media.transmogrifier(input_file: input, output_type: 'image/jpg')
    assert transmog
    status = transmog.run
    assert_equal :success, status
    assert File.exist?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /JPEG/), "output should be a pdf: #{file_info(transmog.output_file)}"
  end

end
