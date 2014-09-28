require 'test_helper'

class Pages::AssetsControllerTest < ActionController::TestCase
  fixtures :users, :groups, :memberships

  def setup
    @page = FactoryGirl.create :page, created_by: users(:blue)
    @asset = @page.add_attachment! uploaded_data: upload_data('photo.jpg')
    users(:blue).updated(@page)
    login_as :blue
  end

  def test_index
    get :index, page_id: @page.id
    assert_response :success
  end

  def test_create_zip
    skip "currently not supporting zip extraction"
    # Need to add an option to the controller and Page#add_attachment!
    # to use Asset#create_from_param_with_zip_extraction
    login_as :blue
    assert_difference '@page.assets.count' do
      post :create, page_id: @page.id,
       assets: [upload_data('subdir.zip')]
    end
    assert_equal 'image/jpeg', Asset.last.content_type
    assert_equal @page.id, Asset.last.page_id
    assert_equal "fox", Asset.last.basename
  end

  def test_may_create
    @page.add(groups(:rainbow), access: :edit).save!
    @page.save!
    login_as :red
    assert_difference '@page.assets.count' do
      post :create, page_id: @page.id,
        asset: {uploaded_data: upload_data('photo.jpg')}
    end
    assert_equal @page.id, Asset.last.page_id
  end

  def test_may_not_create
    @page.add(groups(:rainbow), access: :view).save!
    @page.save!
    login_as :red
    assert_no_difference '@page.assets.count' do
      post :create, page_id: @page.id,
        asset: {uploaded_data: upload_data('photo.jpg')}
      assert_permission_denied
    end
  end

end
