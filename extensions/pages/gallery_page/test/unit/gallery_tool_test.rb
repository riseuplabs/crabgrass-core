require 'test/unit'
require File.dirname(__FILE__) + '/../../../../../test/test_helper'

class GalleryToolTest < ActiveSupport::TestCase

  def setup
    @user = User.make
    @gal = Gallery.create! :title => 'kites', :user => @user
    @asset = Asset.create_from_params(:uploaded_data => upload_data('image.png'))
    @gal.add_image!(@asset)
	end

  def test_properties_after_adding
    assert @asset.is_attachment?
    assert @gal.images.include?(@asset)
    assert @asset.galleries.include?(@gal)
  end

  def test_removing_image
    assert_difference 'Asset.count', -1 do
      assert_nothing_raised do
        @gal.remove_image!(@asset)
      end
    end

    assert !@gal.images.include?(@asset)
    assert_nil Asset.find_by_id(@asset.id)
  end

  def test_sorting_images
    2.times do
      another_asset = Asset.create_from_params(:uploaded_data => upload_data('image.png'))
      @gal.add_image!(another_asset)
    end

    positions = @gal.images.collect{|image| image.id}
    correct_new_positions = [positions.pop] + positions # move the last to the front

    @gal.sort_images(correct_new_positions)

    new_positions = @gal.images(true).collect{|image| image.id}
    assert_equal correct_new_positions, new_positions
  end

  def test_public
    assert !@gal.images.first.public?

    @gal.public = true
    @gal.save
    @gal.images(true).each do |image|
      assert image.public?
    end
  end

  def test_destroy
    assert_difference 'Page.count', -1 do
      assert_difference 'Showing.count', -1 do
        assert_difference 'Asset.count', -1 do
          @gal.destroy
        end
      end
    end
  end

  def test_no_more_duplicates
    gal2 = Gallery.create! :title => 'kittens', :user => @user

    assert_raises PermissionDenied do
      gal2.add_image! @gal.images.first
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
