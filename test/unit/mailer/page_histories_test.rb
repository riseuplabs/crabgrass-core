require 'test_helper'

class Mailer::PageHistoriesTest <  ActionMailer::TestCase
  fixtures :all

  def setup
    @user = users(:blue)
    watch_page
  end

  def teardown
    Conf.paranoid_emails = false
    super
  end

  def test_wont_send_empty_digest
    receive_notifications 'Digest'
    mailer_class.deliver_digests
    assert ActionMailer::Base.deliveries.empty?
  end

  def test_send_plain_digest
    receive_notifications 'Digest'
    updated_page_as users(:red)
    mail = mailer_class.deliver_digests.first
    assert ActionMailer::Base.deliveries.present?
    assert_includes mail.body, "Red! has modified the page title"
  end

  def test_send_paranoid_digest
    with_paranoid_emails
    receive_notifications 'Digest'
    updated_page_as users(:red)
    mail = mailer_class.deliver_digests.first
    assert ActionMailer::Base.deliveries.present?
    assert_includes mail.body, "A page that you are watching has been modified"
    assert_not_includes mail.body, "Red! has modified the page title"
  end

  def test_wont_send_empty_update
    receive_notifications 'Single'
    updated_page_as users(:red), 1.day.ago
    mailer_class.deliver_updates_for page, to: [@user]
    assert ActionMailer::Base.deliveries.empty?
  end

  def test_send_simple_update
    receive_notifications 'Single'
    updated_page_as users(:green), 5.minutes.ago
    updated_page_as users(:red), 1.minute.ago
    mail = mailer_class.deliver_updates_for(page, to: [@user]).first
    assert ActionMailer::Base.deliveries.present?
    assert_includes mail.body, "Red! has modified the page title"
    assert_includes mail.body, "Green! has modified the page title"
  end

  def test_send_paranoid_update
    with_paranoid_emails
    receive_notifications 'Single'
    updated_page_as users(:red), 1.minute.ago
    mail = mailer_class.deliver_updates_for(page, to: [@user]).first
    assert ActionMailer::Base.deliveries.present?
    assert_not_includes mail.body, "Red! has modified the page title"
    assert_includes mail.body, "A page that you are watching has been modified"
  end

  protected

  def with_paranoid_emails
    Conf.paranoid_emails = true
  end

  def mailer_class
    Mailer::PageHistories
  end

  def watch_page
    page.user_participations.where(user_id: @user).create watch: true
  end

  def receive_notifications(type)
    @user.update_attributes receive_notifications: type
  end

  def updated_page_as(user, time = 1.day.ago)
    page.title = 'new title from ' + user.display_name
    page.updated_by user
    page.save
    PageHistory::ChangeTitle.create user: user, page: page, created_at: time
  end

  def page
    @page ||= pages(:blue_page)
  end
end
