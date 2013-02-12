require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/sleepy_transmogrifier'

class TransmogrifierTest < Test::Unit::TestCase

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

  def test_graphicsmagick_transmog
    input = test_file('lyra.png')
    transmog = Media.transmogrifier(:input_file => input, :output_type => 'image/jpg')
    assert_not_nil transmog
    status = transmog.run do |progress|
      debug_progress progress
    end
    assert_equal :success, status
    assert File.exists?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /JPEG/), "output should be a jpg: #{file_info(transmog.output_file)}"
  end

  def test_with_output_file
    input = test_file('lyra.png')
    Media::TempFile.open(nil,'image/jpg') do |dest_file|
      filename = dest_file.to_s
      transmog = Media.transmogrifier(:input_file => input, :output_file => dest_file)
      assert_not_nil transmog, 'should find transmog'
      status = transmog.run
      assert_equal :success, status
      assert File.exists?(dest_file.to_s)
      assert file_info_matches?(dest_file, /JPEG/), "output should be a jpg: #{file_info(transmog.output_file)}"
    end
  end

  def test_libreoffice_transmog
    input = test_file('msword.doc')
    transmog = Media.transmogrifier(:input_file => input, :output_type => 'application/pdf')
    assert_not_nil transmog
    status = transmog.run do |progress|
      debug_progress progress
    end
    assert_equal :success, status
    assert File.exists?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /PDF/), "output should be a pdf: #{file_info(transmog.output_file)}"
  end

  def test_libremagick_transmog
    input = test_file('msword.doc')
    transmog = Media.transmogrifier(:input_file => input, :output_type => 'image/jpg')
    assert_not_nil transmog
    status = transmog.run do |progress|
      debug_progress progress
    end
    assert_equal :success, status
    assert File.exists?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /JPEG/), "output should be a pdf: #{file_info(transmog.output_file)}"
  end

  def test_inkscape_transmog
    input = test_file('anarchism.svg')
    transmog = Media.transmogrifier(:input_file => input, :output_type => 'image/jpg')
    assert_not_nil transmog
    status = transmog.run do |progress|
      debug_progress progress
    end
    assert_equal :success, status
    assert File.exists?(transmog.output_file.to_s)

    assert file_info_matches?(transmog.output_file, /JPEG/), "output should be a pdf: #{file_info(transmog.output_file)}"
  end

end
