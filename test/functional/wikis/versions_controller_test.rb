require_relative '../test_helper'

class Wikis::VersionsControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
    @group  = FactoryGirl.create(:group)
    @group.add_user!(@user)
    @wiki = @group.profiles.public.create_wiki body: 'test'
    @wiki.body = 'more testing'
    @wiki.save
    @version = @wiki.versions.last
    login_as @user
  end

  def test_fetching_version
    run_before_filters :show, wiki_id: @wiki.to_param, id: @version.to_param
    assert_equal @wiki, assigned(:wiki)
    assert_equal @version, assigned(:version)
  end

  def test_version_not_found
    assert_raises ErrorNotFound do
      run_before_filters :show, wiki_id: @wiki.to_param, id: '123'
    end
  end

  def test_show
    assert_permission :may_edit_wiki? do
      get :show, wiki_id: @wiki.to_param, id: @version.to_param
    end
    assert_equal @version, assigns['version']
  end

  def test_index
    assert_permission :may_edit_wiki? do
      get :index, wiki_id: @wiki.to_param
    end
  end

  def test_destroy_not_possible
    assert_raise ActionController::RoutingError do
      delete :destroy, wiki_id: @wiki.to_param, id: @version.to_param
    end
  end

  def test_revert
    login_as @user
    @wiki.body = "revert me"
    @wiki.save
    assert_difference "@wiki.versions.count" do
      assert_permission :may_revert_wiki_version? do
        post :revert, wiki_id: @wiki.to_param, id: @version.to_param
      end
    end
    assert_equal @version.body, @wiki.reload.body
    assert_response :redirect
    assert_redirected_to wiki_versions_url(@wiki)
  end

end
