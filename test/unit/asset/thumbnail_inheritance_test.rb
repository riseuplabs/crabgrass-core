require 'test_helper'

class Asset::ThumbnailInharitanceTest < ActiveSupport::TestCase

  class Asset::Root < Asset
    define_thumbnails foo: {}
  end

  class Asset::Child < Asset::Root
    define_thumbnails bar: {}
  end

  def test_child_inherits_root_thumbdefs
    assert_equal([:foo, :bar], Asset::Child.class_thumbdefs.keys)
  end

  def test_child_thumbdefs_are_isolated
    assert_equal([:foo], Asset::Root.class_thumbdefs.keys)
  end

end
