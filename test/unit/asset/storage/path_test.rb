require 'test_helper'

class Asset::Storage::PathTest < ActiveSupport::TestCase
  def test_private_filename
    assert_equal format('%s/0000/%04d/image.png', ASSET_PRIVATE_STORAGE, asset_id),
                 path.private_filename
  end

  def test_private_thumbnail_filename
    assert_equal format('%s/0000/%04d/image_small.png', ASSET_PRIVATE_STORAGE, asset_id),
                 path.private_filename(thumbnail_filename)
  end

  def test_public_filename
    assert_equal format('%s/%s/image.png', ASSET_PUBLIC_STORAGE, asset_id),
                 path.public_filename
  end

  def test_public_thumbnail_filename
    assert_equal format('%s/%s/image_small.png', ASSET_PUBLIC_STORAGE, asset_id),
                 path.public_filename(thumbnail_filename)
  end

  def test_url
    assert_equal format('/assets/%s/image.png', asset_id), path.url
  end

  def test_thumbnail_url
    assert_equal format('/assets/%s/image_small.png', asset_id),
                 path.url(thumbnail_filename)
  end

  # new api

  def test_versioned_url
    assert_equal format('/assets/%s/versions/3/image_small.png', asset_id),
                 path(version: 3).url(thumbnail_filename)
  end

  protected

  def path(options = {})
    options.reverse_merge! id: asset_id, filename: filename
    Asset::Storage::Path.new options
  end

  def asset_id
    123
  end

  def filename
    'image.png'
  end

  def thumbnail_filename
    'image_small.png'
  end
end
