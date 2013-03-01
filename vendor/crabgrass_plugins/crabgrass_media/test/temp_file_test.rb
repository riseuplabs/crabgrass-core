require_relative 'test_helper'
require 'media/temp_file'

class TempFileTest < Test::Unit::TestCase

  def setup
    @files = []
    100.times do
      @files << Tempfile.new('source')
      @files.last.close
    end
  end

  def test_tempfile_creation_with_move
    temp_files = []
    @files.each do |file|
      temp_files << Media::TempFile.new(file)
    end

    GC.start
    temp_files.each do |file|
      assert File.exists? file.path
    end
  end

end
