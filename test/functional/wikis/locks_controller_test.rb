require_relative '../test_helper'

class Wikis::LocksControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
    @user2  = FactoryGirl.create(:user)
    @group  = FactoryGirl.create(:group)
    @group.add_user! @user
    @group.add_user! @user2
    @wiki = Wiki.create group: @group
    @wiki.lock!(:document, @user)
  end

  def test_destroy_own_lock
    login_as @user
    delete :destroy, wiki_id: @wiki.id
    assert_nil @wiki.reload.section_edited_by(@user)
  end

  def test_cannot_destroy_other_peoples_locks
    login_as @user2
    delete :destroy, wiki_id: @wiki.id
    assert_equal :document, @wiki.reload.section_edited_by(@user)
  end

  def test_cannot_destroy_locks_when_logged_out
    delete :destroy, wiki_id: @wiki
    assert_login_required
    assert_equal :document, @wiki.reload.section_edited_by(@user)
  end

  def test_breaking_lock
    login_as @user2
    put :update, wiki_id: @wiki, break_lock: true
    assert_response :success
    assert_template :edit
    assert_equal [:document], @wiki.reload.sections_open_for(@user2)
    assert_equal [:document], @wiki.reload.sections_locked_for(@user)
  end

  def test_cancel_breaking_lock
    login_as @user2
    put :update, wiki_id: @wiki, cancel: true
    assert_response :success
    assert_template :show
    assert_equal [:document], @wiki.reload.sections_open_for(@user)
    assert_equal [:document], @wiki.reload.sections_locked_for(@user2)
  end

end
