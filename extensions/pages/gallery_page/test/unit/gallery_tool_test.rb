require 'test/unit'
require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class GalleryToolTest < ActiveSupport::TestCase

  def test_add_and_remove
    user = User.make
    gal = Gallery.create! :title => 'kites', :user => user
    a1 = Asset.create_from_params(:uploaded_data => upload_data('image.png'))
    a2 = Asset.create_from_params(:uploaded_data => upload_data('image.png'))

    assert_nothing_raised do
      gal.add_image!(a1, user)
      gal.add_image!(a2)
    end

    assert gal.images.include?(a1)
    assert gal.images.include?(a2)
    assert a1.galleries.include?(gal)
    assert a2.galleries.include?(gal)

    assert_nothing_raised do
      gal.remove_image!(a1)
      gal.remove_image!(a2)
    end

    assert !gal.images.include?(a1)
    assert !gal.images.include?(a2)
    assert !a1.galleries.include?(gal)
    assert !a2.galleries.include?(gal)
  end

  def test_adding_attachment
    user = User.make
    gal = Gallery.create! :title => 'kites', :user => user
    asset = Asset.create_from_params(:uploaded_data => upload_data('image.png'))

    assert_nothing_raised do
      gal.add_image!(asset)
    end

    assert asset.is_attachment?
    assert gal.images.include?(asset)
    assert asset.galleries.include?(gal)

    assert_difference 'Asset.count', -1 do
      assert_nothing_raised do
        gal.remove_image!(asset)
      end
    end

    assert !gal.images.include?(asset)
    assert !asset.galleries.include?(gal)
  end

  def test_position
    user = User.make
    gal = Gallery.create! :title => 'kites', :user => user
    3.times do
      asset = Asset.create_from_params(:uploaded_data => upload_data('image.png'))
      gal.add_image!(asset)
    end

    positions = gal.images.collect{|image| image.id}
    correct_new_positions = [positions.pop] + positions # move the last to the front

    gal.sort_images(correct_new_positions)

    new_positions = gal.images(true).collect{|image| image.id}
    assert_equal correct_new_positions, new_positions
  end

  def test_public
    user = User.make
    gallery = Gallery.create! :title => 'fishies', :user => user do |page|
      page.add_attachment! :uploaded_data => upload_data('image.png')
    end

    gallery.add_image!(gallery.assets.first)
    assert !gallery.images.first.public?

    gallery.public = true
    gallery.save
    gallery.images(true).each do |image|
      assert image.public?
    end
  end

  def test_destroy
    user = User.make
    gallery = nil
    assert_difference 'Page.count' do
      gallery = Gallery.create! :title => 'fishies', :user => user do |page|
        page.add_attachment! :uploaded_data => upload_data('image.png')
      end
      gallery.add_image!(gallery.assets.first)
    end
    assert_difference 'Page.count', -1 do
      assert_difference 'Showing.count', -1 do
        assert_difference 'Asset.count', -1 do
          gallery.destroy
        end
      end
    end
  end

  def test_no_more_duplicates
    user = User.make
    asset1 = Asset.create_from_params(:uploaded_data => upload_data('image.png'))
    gal = Gallery.create! :title => 'kittens', :user => user, :assets => [asset1]
    gal2 = Gallery.create! :title => 'kittens', :user => user

    assert_raises PermissionDenied do
      gal2.add_image! asset1
    end
  end

  #def test_add_before_save
  #  coll = Collection.create! :title => 'kites'
  #  page = DiscussionPage.new :title => 'hi', :collection_id => coll.id
  #  assert page.new_record?
  #  assert page.save
  #  assert !page.new_record?
  #  assert coll.child_pages(true).include?(page)
  #end

  def test_associations
    assert check_associations(Gallery)
    assert check_associations(Showing)
  end

end
