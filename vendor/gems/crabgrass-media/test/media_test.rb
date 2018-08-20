require 'test_helper'
require 'media'

class MediaTest < Minitest::Test

  def test_has_dimensions
    assert Media.has_dimensions? 'image/png'
  end

  def test_has_no_dimensions
    refute Media.has_dimensions? 'text/plain'
  end

end
