require 'test_helper'

class Wiki::VersionsControllerTest < ActionController::TestCase
  def setup
    @user = FactoryGirl.create(:user)
    @group = FactoryGirl.create(:group)
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
    get :show, wiki_id: @wiki.to_param, id: '123'
    assert_response :redirect
    assert_redirected_to action: :index
  end

  def test_show
    assert_permission :may_edit_wiki? do
      get :show, wiki_id: @wiki.to_param, id: @version.to_param
    end
    assert_equal @version, assigns['version']
    assert_equal @wiki.versions.first, assigns['former']
  end

  def test_index
    assert_permission :may_edit_wiki? do
      get :index, wiki_id: @wiki.to_param
    end
  end

  def test_destroy_not_possible
    assert_raise ActionController::UrlGenerationError do
      delete :destroy, wiki_id: @wiki.to_param, id: @version.to_param
    end
  end

  def test_revert
    @wiki.body = 'new version'
    @wiki.save
    assert_difference '@wiki.versions.count' do
      assert_permission :may_revert_wiki_version? do
        post :revert, wiki_id: @wiki.to_param, id: @version.to_param
      end
    end
    assert_equal @original_body, @wiki.reload.body
    assert_response :redirect
    assert_redirected_to wiki_versions_url(@wiki)
  end
end
