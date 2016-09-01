require 'test_helper'

#
# WARNING:
# this test are not isolated since it is using instance objects that for example create a page
# involve create an user participation and that makes create a page_history object, so when you read
# the tests some counts for example seems to not have sense, but this is because of that already created data.
#

class Page::HistoryTest < ActiveSupport::TestCase

  def setup
    Page.delete_all

    @user = FactoryGirl.create(:user, login: "pepe")
    User.current = @user

    @page = FactoryGirl.create(:page, created_by: @user)
    Page::History::PageCreated.create page: @page, user: @user
  end

  def teardown
    Page.delete_all
    User.delete_all
    User.current = nil
  end

  def test_validations
    assert_invalid_attrs user: nil, page: nil
    assert_invalid_attrs user: @user, page: nil
    assert_invalid_attrs user: nil, page: @page
  end

  def test_associations
    page_history = Page::History.create!(user: @user, page: @page)
    assert_equal @user, page_history.user
    assert_kind_of Page, page_history.page
  end

  def test_set_update_at_of_the_page
    post = FactoryGirl.create(:post)
    user = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group)

    page = FactoryGirl.create(:page, created_at: 3.months.ago, updated_at: 2.months.ago)
    Page::History.create!(user: @user, page: page)
    assert_not_change_updated_at page

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::PageCreated.create!(user: @user, page: page)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::UpdatedContent.create!(user: @user, page: page)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::ChangeTitle.create!(user: @user, page: page)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::Deleted.create!(user: @user, page: page)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::AddComment.create!(user: @user, page: page, item: post)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::UpdateComment.create!(user: @user, page: page, item: post)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::DestroyComment.create!(user: @user, page: page, item: post)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::GrantGroupFullAccess.create!(user: @user, page: page, item: group)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::GrantGroupWriteAccess.create!(user: @user, page: page, item: group)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::GrantGroupReadAccess.create!(user: @user, page: page, item: group)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::RevokedGroupAccess.create!(user: @user, page: page, item: group)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::GrantUserFullAccess.create!(user: @user, page: page, item: user)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::GrantUserWriteAccess.create!(user: @user, page: page, item: user)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::GrantUserReadAccess.create!(user: @user, page: page, item: user)

    Page.update_all(["created_at = ?, updated_at = ?", 3.months.ago, 2.months.ago], ["id = ?", page.id])
    assert_change_updated_at page, Page::History::RevokedUserAccess.create!(user: @user, page: page, item: user)
  end

  def test_change_title_saves_old_and_new_value
    page = FactoryGirl.create(:page, title: "Bad title")
    page.update_attribute :title, "Nice title"
    Tracking::Action.track :update_title, user: @user, page: page
    page_history = Page::History::ChangeTitle.find :first, conditions: {page_id: page.id}
    assert_equal "Bad title", page_history.details[:from]
    assert_equal "Nice title", page_history.details[:to]
  end


  def test_recipients_for_single_notifications
    user   = FactoryGirl.create(:user, login: "user", receive_notifications: nil)
    user_a = FactoryGirl.create(:user, login: "user_a", receive_notifications: "Digest")
    user_b = FactoryGirl.create(:user, login: "user_b", receive_notifications: "Single")
    user_c = FactoryGirl.create(:user, login: "user_c", receive_notifications: "Single")

    FactoryGirl.build(:user_participation, page: @page, user: user_a, watch: true).save!
    FactoryGirl.build(:user_participation, page: @page, user: user_b, watch: true).save!
    FactoryGirl.build(:user_participation, page: @page, user: user_c, watch: true).save!

    history = Page::History.last
    assert_equal 2, history.recipients_for_single_notification.count

    history.update_attribute(:user, user_c)
    # user should not receive notifications because he has it disabled
    # user_a should not receive notifications because he has Digest enabled
    # user_b should receive notifications because he has it enabled
    # user_c should not receive_notifications because he was the performer

    assert_equal 1, history.recipients_for_single_notification.count
    assert_equal [user_b], history.recipients_for_single_notification
  end

  private

  def assert_invalid_attrs(attrs)
    history = Page::History.new attrs
    assert !history.valid?,
      "These attributes should be invalid for a Page History: #{attrs.inspect}"
  end

  def assert_change_updated_at(page, page_history)
    page.reload
    page_history.reload
    assert_equal page.updated_at, page_history.created_at
  end

  def assert_not_change_updated_at(page)
    last_updated_at = page.updated_at.to_i
    page.reload
    assert (page.updated_at.to_i - last_updated_at).abs < 2
  end
end
