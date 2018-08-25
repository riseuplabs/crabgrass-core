require 'test_helper'

class Wiki::VersionsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @group = FactoryBot.create(:group)
    @group.add_user!(@user)
    @wiki = @group.profiles.public.create_wiki body: 'test'
    @wiki.body = @original_body = 'original wiki body'
    @wiki.updated_at = 1.day.ago # force an older timestamp, so that
    # changing the wiki will create a new version.
    @wiki.save
    @version = @wiki.versions.last
    login_as @user
  end

  def test_version_not_found
    get :show, params: { wiki_id: @wiki.to_param, id: '123' }
    assert_response :redirect
    assert_redirected_to action: :index
  end

  def test_show
    get :show, params: { wiki_id: @wiki.to_param, id: @version.to_param }
    assert_equal @version, assigns['version']
    assert_equal @wiki.versions.first, assigns['former']
  end

  def test_index
    get :index, params: { wiki_id: @wiki.to_param }
    assert_response :success
  end

  def test_destroy_not_possible
    assert_raise ActionController::UrlGenerationError do
      delete :destroy, params: { wiki_id: @wiki.to_param, id: @version.to_param }
    end
  end

end
