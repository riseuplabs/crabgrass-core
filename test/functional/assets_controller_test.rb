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
    @controller.stubs(:public_or_login_required).returns(true)
    @controller.expects(:private_filename).returns(asset.private_filename)
    get :show, :id => asset.id, :path => asset.filename
    @controller.expects(:private_filename).returns(thumbnail(asset.private_filename))
    get :show, :id => asset.id, :path => thumbnail(asset.filename)
  end

  private

  def thumbnail(path)
    path.sub('.jpg', '_small.jpg')
  end

end
