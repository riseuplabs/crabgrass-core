require File.dirname(__FILE__) + '/../../test_helper'

class Wikis::WikisControllerTest < ActionController::TestCase

  def setup
    @user = User.make
    @group = Group.make
    @group.add_user!(@user)
  end


  def test_edit
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    login_as @user
    assert_permission :may_edit_wiki? do
      xhr :get, :edit, :id => @wiki.id
    end
    assert_response :success
    assert_template 'wikis/wikis/edit.rjs'
    assert_equal @group, assigns(:group)
    assert_equal @wiki, assigns['wiki']
    assert_equal @group, assigns['context'].entity
    assert_equal @user, @wiki.reload.locker_of(:document)
  end

  def test_edit_locked
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    other_user = User.make
    @wiki.lock! :document, other_user
    login_as @user
    assert_permission :may_edit_wiki? do
      xhr :get, :edit, :id => @wiki.id
    end
    assert_response :success
    assert_template 'wikis/wikis/locked.rjs'
    assert_equal other_user, @wiki.locker_of(:document)
    assert_equal @wiki, assigns['wiki']
  end

  def test_update
    @wiki = @group.profiles.public.create_wiki :body => 'init'
    login_as @user
    assert_permission :may_edit_wiki? do
      xhr :post, :update,
        :id => @wiki.id,
        :wiki => {:body => '*updated*', :version => 1}
    end
    assert_response :redirect
    assert_redirected_to group_url(@group)
    assert_equal "<p><strong>updated</strong></p>", @wiki.reload.body_html
  end

end
