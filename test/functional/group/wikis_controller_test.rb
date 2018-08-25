require 'test_helper'

class Group::WikisControllerTest < ActionController::TestCase
  def setup
    @user = users(:blue)
    @group = groups(:rainbow)
    @group2 = groups(:groupwithcouncil)# all members may edit the wiki is false
    @user2 = users(:dolphin)# not a member of rainbow
    @user3 = users(:red) # not in council of groupwithcouncil
  end

  def test_show_wiki_settings
    login_as @user
    get :index, params: { group_id: @group.to_param }, xhr: true
    assert_response :success
  end

  def test_show_wiki_settings_no_member
    login_as @user2
    assert_permission_denied do
      get :index, params: { group_id: @group.to_param }, xhr: true
    end
  end

  # TODO: maybe another test wich proves that
  # settings will not be shown to non-council members -
  # no matter if the settings allow them to edit the
  # group wiki
  def test_show_wiki_settings_no_council_member
    login_as @user3
    assert_permission_denied do
      get :index, params: { group_id: @group2.to_param }, xhr: true
    end
  end

  def test_create_private_wiki
    login_as @user
    post :create, params: { group_id: @group.to_param, profile: :private, wiki: { body: "_created_" } }, xhr: true
    wiki = Wiki.last
    assert '<em>created</em>', wiki.body_html
    assert wiki.profile.private?
    assert_equal @user, wiki.versions.last.user
    assert_response :redirect
    assert_redirected_to group_wikis_url(@group, anchor: :private)
  end

  def test_create_private_wiki_not_allowed
    login_as @user2
    assert_permission_denied do
      post :create, params: { group_id: @group.to_param, profile: :private }, xhr: true
    end
  end

  def test_new_private_with_existing_public_wiki
    login_as @user
    @wiki = @group.profiles.public.create_wiki body: 'init'
    post :create, params: { group_id: @group.to_param, profile: :private, wiki: { body: "_private_stuff_" } }, xhr: true
    wiki = Wiki.last
    assert '<em>private stuff</em>', wiki.body_html
    assert wiki.profile.private?
    assert_response :redirect
  end

  def test_create_public_wiki
    login_as @user
    post :create, params: { group_id: @group.to_param, profile: :public, wiki: { body: "_created_" } }, xhr: true
    wiki = Wiki.last
    assert '<em>created</em>', wiki.body_html
    assert wiki.profile.public?
    assert_response :redirect
    assert_redirected_to group_wikis_url(@group, anchor: :public)
  end
end
