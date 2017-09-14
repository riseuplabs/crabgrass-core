require 'test_helper'

class ThumbnailTest < ActiveSupport::TestCase
  def test_associations
    assert check_associations(Thumbnail)
  end
end
