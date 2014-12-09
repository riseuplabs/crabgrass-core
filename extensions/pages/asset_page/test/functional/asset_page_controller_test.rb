require 'test_helper'

class AssetPageControllerTest < ActionController::TestCase
  fixtures :users, :groups, :sites

  def setup
    setup_assets
    @asset = Asset.create_from_params uploaded_data: upload_data('photo.jpg')
  end

  def teardown
    teardown_assets
  end

  def test_show
    page = create_page data: @asset, public: true

    post :show, id: page.id
    assert_response :success
    assert_template 'show'
    assert_equal @asset.private_filename, assigns(:asset).private_filename,
      "should fetch the correct file"
  end


  def test_update
    login_as :gerrard

    create_page created_by: users(:gerrard), asset: @asset

    assert_difference 'Asset::Version.count', 1, "jpg should version" do
      post 'update', id: @page.id,
        asset: {uploaded_data: upload_data('photo.jpg')}
    end
  end

  def test_updated_by
    page = AssetPage.create title: 'hi',
      user: users(:blue),
      share_with: users(:kangaroo),
      access: 'edit',
      data: @asset
    assert_equal users(:blue).id, page.updated_by_id

    login_as :kangaroo
    post 'update', id: page.id,
      asset: {uploaded_data: upload_data('photo.jpg')}
    assert_equal 'kangaroo', page.reload.updated_by_login
  end

  protected
  def create_page(options = {})
    defaults = {title: 'untitled page', public: false}
    @page = AssetPage.create(defaults.merge(options))
  end
end
