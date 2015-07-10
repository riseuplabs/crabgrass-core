require 'integration_test'

class AssetTest < IntegrationTest

  def test_get_asset
    asset = FactoryGirl.create :image_asset
    visit asset.url
    assert_equal 200, status_code
  end


  # we used to have some iso encoding so links would escape to
  # strings include %F3.
  # Now this old link will lead to utf-8 errors as the chars > \xF0 are
  # invalid. Let's make sure the old link still works...
  def test_get_asset_with_strange_char
    asset = FactoryGirl.create :image_asset
    visit asset.url.sub('.jpg', '%F3.jpg')
    assert_equal 200, status_code
    visit asset.url.sub('.jpg', '%F3.jpg')
    assert_equal 200, status_code
  end
end


