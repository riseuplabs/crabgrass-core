require 'test_helper'

class Wiki::LocksControllerTest < ActionController::TestCase
  def setup
    @user = FactoryBot.create(:user)
    @user2  = FactoryBot.create(:user)
    @group  = FactoryBot.create(:group)
    @group.add_user! @user
    @group.add_user! @user2
    @wiki = Wiki.create group: @group
    @wiki.lock!(:document, @user)
  end

  def test_section_not_found
    @wiki = Wiki.create group: @group
    login_as @user
    xhr :delete, :destroy, wiki_id: @wiki.id, section: :bla
    assert_response :not_found
  end

  def test_destroy_own_lock
    login_as @user
    xhr :delete, :destroy, wiki_id: @wiki.id
    assert_nil @wiki.reload.section_edited_by(@user)
  end

  def test_cannot_destroy_other_peoples_locks
    login_as @user2
    xhr :delete, :destroy, wiki_id: @wiki.id
    assert_equal :document, @wiki.reload.section_edited_by(@user)
  end

  def test_cannot_destroy_locks_when_logged_out
    assert_raises AuthenticationRequired do
      xhr :delete, :destroy, wiki_id: @wiki
    end
  end

  def test_breaking_lock
    login_as @user2
    put :update, params: { wiki_id: @wiki, break_lock: true }
    assert_response :success
    assert_template :edit
    assert_equal [:document], @wiki.reload.sections_open_for(@user2)
    assert_equal [:document], @wiki.reload.sections_locked_for(@user)
  end

  def test_cancel_breaking_lock
    login_as @user2
    put :update, params: { wiki_id: @wiki, cancel: true }
    assert_response :success
    assert_template :show
    assert_equal [:document], @wiki.reload.sections_open_for(@user)
    assert_equal [:document], @wiki.reload.sections_locked_for(@user2)
  end
end
