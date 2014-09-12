require_relative 'test_helper'

class Pages::AttachmentTest < ActiveSupport::TestCase

  fixtures :pages, :users, :groups, :polls

  def setup
    PageHistory.delete_all
    setup_assets
  end

  def teardown
    PageHistory.delete_all
    # ensure there are no tempfiles left and getting removed
    # some random time.
    GC.start
    teardown_assets
  end

  def test_attachments
    setup_assets
    page = Page.create! :title => 'page with attachments', :user => users(:blue)
    upload = upload_data('gears.jpg')
    page.add_attachment! :uploaded_data => upload

    assert_equal page.page_terms, page.assets.first.page_terms

    assert_equal 'gears.jpg', page.assets.first.filename
    page.assets.each do |asset|
      assert !asset.public?
    end

    page.public = true
    page.save

    page.assets(true).each do |asset|
      assert asset.public?
    end

    assert_difference('Page.count', -1) do
      assert_difference('Asset.count', -1) do
        page.destroy
      end
    end
  end

  def test_attachment_options
    asset = Asset.create! :uploaded_data => upload_data('photo.jpg')
    page = Page.create! :title => 'page with attachments'
    page.add_attachment! asset, :filename => 'picture', :cover => true

    assert_equal 'picture.jpg', page.assets.first.filename
    assert_equal asset, page.cover
  end

  def test_attachment_building
    # make sure we don't create assets when we create invalid pages
    assert_no_difference 'Page.count' do
      assert_no_difference 'Asset.count' do
        assert_raises ActiveRecord::RecordInvalid do
          Page.create! do |page|
            page.add_attachment! :uploaded_data => upload_data('photo.jpg')
          end
        end
      end
    end
    assert_difference 'Page.count' do
      assert_difference 'Asset.count' do
        assert_nothing_raised do
          page = Page.create!(:title => 'hi') do |page|
            page.add_attachment! :uploaded_data => upload_data('photo.jpg')
          end
          assert_equal 'photo.jpg', page.assets.first.filename
        end
      end
    end
  end

end
