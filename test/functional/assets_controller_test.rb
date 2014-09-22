require_relative 'test_helper'

class AssetsControllerTest < ActionController::TestCase

  def test_get_permissions
    ImageAsset.any_instance.stubs(:public?).returns(false)
    asset = FactoryGirl.create :image_asset
    get :show, :id => asset.id, :path => asset.filename
    assert_login_required
  end

  def test_thumbnail_get
    ImageAsset.any_instance.stubs(:public?).returns(false)
    asset = FactoryGirl.create :image_asset
    @controller.stubs(:authorized?).returns(true)
    @controller.expects(:private_filename).returns(asset.private_filename)
    get :show, :id => asset.id, :path => asset.filename
    @controller.expects(:private_filename).returns(thumbnail(asset.private_filename))
    get :show, :id => asset.id, :path => thumbnail(asset.filename)
  end

  def test_destroy
    user = FactoryGirl.create :user
    page = FactoryGirl.create :page, :created_by => user
    asset = page.add_attachment! :uploaded_data => upload_data('photo.jpg')
    user.updated(page)
    login_as user
    assert_difference 'page.assets.count', -1 do
      delete :destroy, :id => asset.id, :page_id => page.id
    end
  end


  private

  def thumbnail(path)
    path.sub('.jpg', '_small.jpg')
  end

end
