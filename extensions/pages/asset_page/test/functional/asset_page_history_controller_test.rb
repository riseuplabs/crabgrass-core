require 'test_helper'

class AssetPageHistoryControllerTest < ActionController::TestCase
  fixtures :users, :groups, :sites

  def setup
    setup_assets
    @asset = Asset.create_from_params uploaded_data: upload_data('photo.jpg')
  end

  def teardown
    teardown_assets
  end

  def test_destroy
    user = users(:gerrard)
    login_as user
    create_page created_by: user, asset: @asset

    @asset = @page.data
    @version_filename = @asset.versions.find_by_version(1).private_filename
    @asset.uploaded_data = upload_data('photo.jpg')
    @asset.user = user
    @asset.save
    user.updated(@page)

    assert_difference 'Asset::Version.count', -1, "destroy should remove a version" do
      post :destroy, page_id: @page, id: 1
    end
    assert File.exists?(@asset.private_filename)
    assert !File.exists?(@version_filename)

    assert_equal 1, @asset.reload.versions.size
  end

  protected
  def create_page(options = {})
    defaults = {title: 'untitled page', public: false}
    @page = AssetPage.create(defaults.merge(options))
  end
end
