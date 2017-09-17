require 'test_helper'

class ImageHelperTest < ActiveSupport::TestCase
  class ViewMock
    include Common::Ui::ImageHelper

    def image_tag(*args)
      @args = args
    end

    def image_tag_args
      @args
    end
  end

  def test_stub
    assert ViewMock.include? Common::Ui::ImageHelper
  end

  def test_fallback
    mock.thumbnail_img_tag asset_without_thumbs, :medium
    assert_called_image_tag_with '/images/png/16/mime_image.png',
                                 style: 'vertical-align: middle;'
  end

  def test_medium_thumbnail
    mock.thumbnail_img_tag asset, :medium
    assert_called_image_tag_with '/assets/1/bee_medium.jpg',
                                 size: '133x200'
  end

  def test_large_thumbnail
    mock.thumbnail_img_tag asset, :large
    assert_called_image_tag_with '/assets/1/bee_large.jpg',
                                 size: '333x500'
  end

  def test_crop_thumbnail
    mock.thumbnail_img_tag asset, :large, crop: '100x100'
    assert_called_image_tag_with '/assets/1/bee_large.jpg',
                                 size: '100x150'
  end

  def test_scale_thumbnail
    mock.thumbnail_img_tag asset, :large, scale: '100x100'
    assert_called_image_tag_with '/assets/1/bee_large.jpg',
                                 size: '67x100'
  end

  protected

  def asset
    asset = asset_without_thumbs
    asset.create_thumbnail_records
    asset
  end

  def asset_without_thumbs
    assets(:bee)
  end

  def assert_called_image_tag_with(*args)
    assert_equal args, mock.image_tag_args
  end

  def mock
    @mock ||= ViewMock.new
  end
end
