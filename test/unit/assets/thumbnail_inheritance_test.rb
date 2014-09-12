require_relative '../test_helper'

class Assets::ThumbnailInharitanceTest < ActiveSupport::TestCase

  class RootAsset < Asset
    define_thumbnails :foo => {}
  end

  class ChildAsset < RootAsset
    define_thumbnails :bar => {}
  end

  def test_child_inherits_root_thumbdefs
    assert_equal([:foo, :bar], ChildAsset.class_thumbdefs.keys)
  end

  def test_child_thumbdefs_are_isolated
    assert_equal([:foo], RootAsset.class_thumbdefs.keys)
  end

end
