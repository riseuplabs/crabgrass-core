require File.dirname(__FILE__) + '/../../test_helper'

class Groups::WikisControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user!(@user)
  end

  def test_new
    login_as @user
    assert_permission :may_create_group_wiki? do
      xhr :get, :new, :group_id => @group.to_param
    end
    assert_response :success
    assert assigns['wiki'].new_record?
  end

  def test_new_private_wiki
    login_as @user
    xhr :get, :new, :group_id => @group.to_param, :private => true
    assert_response :success
    assert assigns['wiki'].new_record?
    assert_select 'input#wiki_private[type="hidden"][value="true"]'
  end

  def test_new_with_existing_wiki
    login_as @user
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    xhr :get, :new, :group_id => @group.to_param
    assert_response :success
    assert !assigns['wiki'].new_record?
    assert_equal @wiki, assigns['wiki']
  end

  def test_new_with_existing_private_wiki
    login_as @user
    @wiki = @group.profiles.private.create_wiki :body => 'init'
    xhr :get, :new, :group_id => @group.to_param, :private => true
    assert_response :success
    assert !assigns['wiki'].new_record?
    assert_equal @wiki, assigns['wiki']
  end

  def test_new_private_with_existing_public_wiki
    login_as @user
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    xhr :get, :new, :group_id => @group.to_param, :private => true
    assert_response :success
    assert assigns['wiki'].new_record?
    assert_select 'input#wiki_private[type="hidden"][value="true"]'
  end

  def test_create_private
    login_as @user
    assert_permission :may_create_group_wiki? do
      xhr :post, :create,
        :group_id => @group.to_param,
        :wiki => { :body => "_created_", :private => true }
    end
    wiki = Wiki.last
    assert "<em>created</em>", wiki.body_html
    assert wiki.profile.private?
    assert_response :redirect
    assert_redirected_to group_url(@group)
  end

  def test_create_public
    login_as @user
    assert_permission :may_create_group_wiki? do
      xhr :post, :create,
        :group_id => @group.to_param,
        :wiki => { :body => "_created_", :private => false }
    end
    wiki = Wiki.last
    assert "<em>created</em>", wiki.body_html
    assert wiki.profile.public?
    assert_response :redirect
    assert_redirected_to group_url(@group)
  end

  def test_create_with_existing_wiki
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    login_as @user
    assert_difference '@wiki.versions.count' do
      xhr :post, :create,
        :group_id => @group.to_param,
        :wiki => { :body => "_created_", :private => false }
    end
    wiki = Wiki.last
    assert "<em>created</em>", wiki.body_html
    assert wiki.profile.public?
    assert_response :redirect
    assert_redirected_to group_url(@group)
  end

  def test_show_private
    @wiki = @group.profiles.private.create_wiki :body => 'init'
    login_as @user
    assert_permission :may_show_group_wiki? do
      xhr :get, :show, :group_id => @group.to_param, :id => @wiki.id
    end
    assert_response :success
    assert_equal @wiki, assigns['wiki']
  end

  def test_show_to_stranger
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    assert_permission :may_show_group_wiki? do
      xhr :get, :show, :group_id => @group.to_param, :id => @wiki.id
    end
    assert_response :success
    assert_equal @wiki, assigns['wiki']
  end

  def test_do_not_show_private_to_stranger
    @priv = @group.profiles.private.create_wiki :body => 'private'
    assert_permission(:may_show_group_wiki?, false) do
      xhr :get, :show, :group_id => @group.to_param, :id => @priv.id
    end
  end

  def test_edit
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    login_as @user
    assert_permission :may_edit_group_wiki? do
      xhr :get, :edit, :group_id => @group.to_param, :id => @wiki.id
    end
    assert_response :success
    assert_template 'common/wiki/edit.rjs'
    assert_equal @wiki, assigns['wiki']
    assert_equal @user, @wiki.reload.locker_of(:document)
  end

  def test_edit_locked
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    other_user = User.make
    @wiki.lock! :document, other_user
    login_as @user
    assert_permission :may_edit_group_wiki? do
      xhr :get, :edit, :group_id => @group.to_param, :id => @wiki.id
    end
    assert_response :success
    assert_template 'common/wiki/locked.rjs'
    assert_equal other_user, @wiki.locker_of(:document)
    assert_equal @wiki, assigns['wiki']
  end

  def test_update
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    login_as @user
    assert_permission :may_edit_group_wiki? do
      xhr :post, :update,
        :group_id => @group.to_param,
        :id => @wiki.id,
        :wiki => {:body => '*updated*', :version => 1}
    end
    assert_response :redirect
    assert_redirected_to group_url(@group)
    assert_equal "<p><strong>updated</strong></p>", @wiki.reload.body_html
  end

end
