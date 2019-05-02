require 'test_helper'

#
# WARNING:
# this test are not isolated since it is using instance objects that for
# example create a page involve create an user participation and that
# makes create a page_history object, so when you read the tests some
# counts for example seems to not have sense, but this is because of
# that already created data.
#

class Page::HistoryTest < ActiveSupport::TestCase
  def setup
    Page.delete_all

    @user = FactoryBot.create(:user, login: 'pepe')

    @page = FactoryBot.create(:page, created_by: @user)
    Page::History::PageCreated.create page: @page, user: @user
  end

  def teardown
    Page.delete_all
    User.delete_all
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
    post = FactoryBot.create(:post)
    user = FactoryBot.create(:user)
    group = FactoryBot.create(:group)

    page = FactoryBot.create :page,
      created_at: 3.months.ago,
      updated_at: 2.months.ago

    refute_touches page, Page::History

    assert_touches page, Page::History::PageCreated
    assert_touches page, Page::History::UpdatedContent
    assert_touches page, Page::History::ChangeTitle
    assert_touches page, Page::History::Deleted
    assert_touches page, Page::History::AddComment, item: post
    assert_touches page, Page::History::UpdateComment, item: post
    assert_touches page, Page::History::DestroyComment, item: post
    assert_touches page, Page::History::GrantGroupFullAccess, item: group
    assert_touches page, Page::History::GrantGroupWriteAccess, item: group
    assert_touches page, Page::History::GrantGroupReadAccess, item: group
    assert_touches page, Page::History::RevokedGroupAccess, item: group
    assert_touches page, Page::History::GrantUserFullAccess, item: user
    assert_touches page, Page::History::GrantUserWriteAccess, item: user
    assert_touches page, Page::History::GrantUserReadAccess, item: user
    assert_touches page, Page::History::RevokedUserAccess, item: user
  end

  def test_change_title_saves_old_and_new_value
    page = FactoryBot.create(:page, title: 'Bad title')
    page.update_attribute :title, 'Nice title'
    Tracking::Action.track :update_title, user: @user, page: page
    page_history = Page::History::ChangeTitle.where(page_id: page).first
    assert_equal 'Bad title', page_history.details[:from]
    assert_equal 'Nice title', page_history.details[:to]
  end

  def test_change_title_saves_old_and_new_value
    page = FactoryBot.create(:page, title: 'Bad title')
    page.update_attribute :title, 'Nice title which is far too long and has to be truncated to be saved. We had to truncate the title, because there were titles which did not fit into the database'
    Tracking::Action.track :update_title, user: @user, page: page
    page_history = Page::History::ChangeTitle.where(page_id: page).first
    assert_equal 'Bad title', page_history.details[:from]
    assert_equal 'Nice title which is far too long and has to be truncated to be saved. We had to truncate the...', page_history.details[:to]
  end

  def test_recipients_for_single_notifications
    user   = FactoryBot.create(:user, receive_notifications: nil)
    user_a = FactoryBot.create(:user, receive_notifications: 'Digest')
    user_b = FactoryBot.create(:user, receive_notifications: 'Single')
    user_c = FactoryBot.create(:user, receive_notifications: 'Single')

    watch_page user
    watch_page user_a
    watch_page user_b
    watch_page user_c

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

  def watch_page(user)
    part = FactoryBot.build :user_participation,
      page: @page,
      user: user,
      watch: true
    part.save!
  end

  def assert_invalid_attrs(attrs)
    history = Page::History.new attrs
    refute history.valid?,
           "failed to detect these invalid attributes: #{attrs.inspect}"
  end

  def assert_touches(page, klass, options = {})
    Page.where(id: page).update_all created_at: 3.months.ago,
                                    updated_at: 2.months.ago
    page_history = klass.create! options.merge(user: @user, page: page)
    page.reload
    page_history.reload
    assert_equal page.updated_at, page_history.created_at
  end

  def refute_touches(page, klass, options = {})
    Page.where(id: page).update_all created_at: 2.months.ago,
                                    updated_at: 2.months.ago
    assert_no_difference 'page.reload.updated_at' do
      klass.create! options.merge(user: @user, page: page)
    end
  end
end
