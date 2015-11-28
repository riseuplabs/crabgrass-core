require 'test_helper'

class Mailer::PageHistoriesTest <  ActionMailer::TestCase
  fixtures :all

  def setup
    @user = users(:blue)
    watch_page
  end

  def test_wont_send_empty_mails
    receive_notifications 'Digest'
    mailer_class.deliver_digests
    assert ActionMailer::Base.deliveries.empty?
  end

  def test_send_simple_digest
    receive_notifications 'Digest'
    updated_page_as users(:red)
    mail = mailer_class.deliver_digests.first
    assert ActionMailer::Base.deliveries.present?
    assert_includes mail.body, "Red! has modified the page title"
  end

  def test_send_paranoid
    receive_notifications 'Digest'
    updated_page_as users(:red)
    Conf.paranoid_emails = true
    mail = mailer_class.deliver_digests.first
    assert ActionMailer::Base.deliveries.present?
    assert_includes mail.body, "A page that you are watching has been modified"
    assert_not_includes mail.body, "Red! has modified the page title"
  ensure
    Conf.paranoid_emails = false
  end

  protected

  def mailer_class
    Mailer::PageHistories
  end

  def watch_page
    page.user_participations.where(user_id: @user).create watch: true
  end

  def receive_notifications(type)
    @user.update_attributes receive_notifications: type
  end

  def updated_page_as(user)
    page.title = 'new title'
    page.updated_by user
    PageHistory::ChangeTitle.create user: user, page: page, created_at: 1.day.ago
  end

  def page
    @page ||= pages(:blue_page)
  end
end
