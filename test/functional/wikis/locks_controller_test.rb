require_relative '../test_helper'

class Wikis::LocksControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
    @user2  = FactoryGirl.create(:user)
    @group  = FactoryGirl.create(:group)
    @group.add_user! @user
    @group.add_user! @user2
    @wiki = Wiki.create :group => @group
    @wiki.lock!(:document, @user)
  end

  def test_destroy_own_lock
    login_as @user
    delete :destroy, :wiki_id => @wiki.id
    assert_nil @wiki.reload.section_edited_by(@user)
  end

  def test_cannot_destroy_other_peoples_locks
    login_as @user2
    delete :destroy, :wiki_id => @wiki.id
    assert_equal :document, @wiki.reload.section_edited_by(@user)
  end

  def test_cannot_destroy_locks_when_logged_out
    delete :destroy, :wiki_id => @wiki.id
    assert_login_required
    assert_equal :document, @wiki.reload.section_edited_by(@user)
  end
end
