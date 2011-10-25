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
      get :new, :group_id => @group.to_param
    end
    assert_response :success
    assert assigns['wiki'].new_record?
    #TODO: how do we do locking for new wikis?
  end

  def test_create_private
    login_as @user
    assert_permission :may_create_group_wiki? do
      post :create,
        :group_id => @group.to_param,
        :wiki => { :body => "_created_", :private => true }
    end
    assert_response :success
    assert wiki = assigns['wiki']
    assert "<em>created</em>", wiki.body_html
    assert wiki.profile.private?
  end

  def test_create_public
    login_as @user
    assert_permission :may_create_group_wiki? do
      post :create,
        :group_id => @group.to_param,
        :wiki => { :body => "_created_", :private => false }
    end
    assert_response :success
    assert wiki = assigns['wiki']
    assert "<em>created</em>", wiki.body_html
    assert wiki.profile.public?
  end

  def test_show
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    login_as @user
    assert_permission :may_show_group_wiki? do
      get :show, :group_id => @group.to_param, :id => @wiki.id
    end
    assert_response :success
    assert_equal @wiki, assigns['wiki']
  end

  def test_edit
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    login_as @user
    assert_permission :may_edit_group_wiki? do
      get :edit, :group_id => @group.to_param, :id => @wiki.id
    end
    assert_response :success
    assert_equal @wiki, assigns['wiki']
    # TODO: assert @wiki.document_locked_for? @user
  end

  def test_update
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    login_as @user
    assert_permission :may_edit_group_wiki? do
      post :update,
        :group_id => @group.to_param,
        :id => @wiki.id,
        :wiki => {:body => '*updated*', :version => 1}
    end
    assert_response :success
    assert_equal "<b>updated</b>", assigns['wiki'].body_html
  end

end
