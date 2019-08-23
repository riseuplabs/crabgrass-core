require 'test_helper'

class AssetsControllerTest < ActionController::TestCase
  include AssetTestHelper

  def setup
    super
    setup_assets
  end

  def teardown
    teardown_assets
    super
  end

  def test_get_permissions
    page = FactoryBot.create :page
    asset = FactoryBot.create :image_asset, parent_page: page
    get :show, params: { id: asset.id, path: asset.basename }
    assert_permission_denied
  end

  def test_get_with_escaped_chars
    asset = FactoryBot.create :image_asset
    get :show, params: { id: asset.id, path: asset.basename + '\xF3' }
    assert_response :redirect
    get :show, params: { id: asset.id, path: asset.basename + '\xF3' }
    assert_response :success
  end

  def test_not_found
    assert_raises ActiveRecord::RecordNotFound do
      get :show, params: { id: :non_existant }
    end
  end

  def test_not_found_with_version
    assert_raises ActiveRecord::RecordNotFound do
      get :show, params: { id: :non_existant, version: 123 }
    end
  end

  def test_thumbnail_get
    asset = FactoryBot.create :image_asset
    get :show, params: { id: asset.id, path: thumbnail(asset.basename) }
    assert_response :redirect
    get :show, params: { id: asset.id, path: thumbnail(asset.basename) }
    assert_response :success
  end

  def test_destroy
    user = FactoryBot.create :user
    page = FactoryBot.create :page, created_by: user
    asset = page.add_attachment! uploaded_data: upload_data('photo.jpg')
    user.updated(page)
    login_as user
    assert_difference 'page.assets.count', -1 do
      delete :destroy, params: { id: asset.id, page_id: page.id }
    end
  end

  def test_destroy_not_allowed
    user = FactoryBot.create :user
    page = FactoryBot.create :page, created_by: users(:blue)
    asset = page.add_attachment! uploaded_data: upload_data('photo.jpg')
    user.updated(page)
    login_as user
    delete :destroy, params: { id: asset.id, page_id: page.id }
    assert_permission_denied
  end

  private

  def thumbnail(path)
    ext = File.extname(path)
    path.sub(/#{ext}$/, "_small#{ext}")
  end

end
