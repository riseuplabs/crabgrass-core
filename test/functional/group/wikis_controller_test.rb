require 'test_helper'

class Group::WikisControllerTest < ActionController::TestCase
  def setup
    @user = users(:blue)
    @group = groups(:rainbow)
    @user2 = users(:dolphin)# not a member of rainbow
  end

  def test_show_wiki_settings
    login_as @user
    xhr :get, :index, group_id: @group.to_param
    assert_response :success
  end

  def test_show_wiki_settings_not_allowed
    login_as @user2
    assert_permission_denied do
      xhr :get, :index, group_id: @group.to_param
    end
  end

  def test_create_private_wiki
    login_as @user
    xhr :post, :create,
      group_id: @group.to_param, profile: :private,
        wiki: { body: '_created_'}
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
      xhr :post, :create, group_id: @group.to_param, profile: :private
    end
  end

  def test_new_private_with_existing_public_wiki
    login_as @user
    @wiki = @group.profiles.public.create_wiki body: 'init'
    xhr :post, :create, group_id: @group.to_param, profile: :private,
      wiki: { body: '_private_stuff_'}
    wiki = Wiki.last
    assert '<em>private stuff</em>', wiki.body_html
    assert wiki.profile.private?
    assert_response :redirect
  end

  def test_create_public_wiki
    login_as @user
    xhr :post, :create,
      group_id: @group.to_param, profile: :public,
        wiki: { body: '_created_' }
    wiki = Wiki.last
    assert '<em>created</em>', wiki.body_html
    assert wiki.profile.public?
    assert_response :redirect
    assert_redirected_to group_wikis_url(@group, anchor: :public)
  end

  # FIXME: does not increment versions
  def xtest_create_with_existing_wiki
    @wiki = @group.profiles.public.create_wiki body: 'init'
    @wiki.update_attribute :updated_at, 2.weeks.ago
    @wiki.save
    login_as @user
    assert_difference '@wiki.versions.count' do
      xhr :post, :create,
          group_id: @group.to_param, profile: :public,
          wiki: { body: '_new vesion_' }
    end
    wiki = Wiki.last
    assert '<em>_new version_</em>', wiki.body_html
    assert wiki.profile.public?
    assert_response :redirect
    assert_redirected_to group_wikis_url(@group, anchor: :public)
  end
end
