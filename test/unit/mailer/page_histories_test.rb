require 'test_helper'

class Mailer::PageHistoriesTest < ActionMailer::TestCase

  def setup
    # only :blue (and :dolphin) have a valid key. :red's is broken, :yellow's is expired and green
    # does not have a key
    @user = users(:blue)
    watch_page
    ActionMailer::Base.default_url_options = {:host => 'localhost:3000'}
    mailer_class.deliveries = nil
  end

  def teardown
    Conf.paranoid_emails = false
    super
  end

  def test_wont_encrypt_without_key
    @user = users(:yellow)
    watch_page
    receive_notifications 'Digest'
    updated_page_as users(:blue)
    mail = mailer_class.deliver_digests.first
    assert_includes mail.body, 'Blue! has modified the page title'
    assert_not mailer_class.deliveries.first.encrypted?
  end

  def test_encrypt_with_expired_key
    @user = users(:green)
    watch_page
    receive_notifications 'Digest'
    updated_page_as users(:blue)
    assert_raise Mail::Gpg::MissingKeysError do
      mail = mailer_class.deliver_digests.first
    end
  end

  def test_encrypt_with_broken_key
    @user = users(:red)
    watch_page
    receive_notifications 'Digest'
    updated_page_as users(:blue)
    assert_raise Mail::Gpg::MissingKeysError do
      mail = mailer_class.deliver_digests.first
    end
  end

  def test_wont_send_empty_digest
    receive_notifications 'Digest'
    assert_empty mailer_class.deliver_digests.first
    assert_not mailer_class.deliveries.present?
  end

  def test_send_plain_digest_encrypted
    receive_notifications 'Digest'
    updated_page_as users(:red)
    mail = mailer_class.deliver_digests.first
    assert mailer_class.deliveries.present?
    assert_includes mail.body, 'Red! has modified the page title'
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_send_paranoid_digest_encrypted
    with_paranoid_emails
    receive_notifications 'Digest'
    updated_page_as users(:red)
    mail = mailer_class.deliver_digests.first
    assert mailer_class.deliveries.present?
    assert_includes mail.body, 'A page that you are watching has been modified'
    assert_not_includes mail.body, 'Red! has modified the page title'
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_wont_send_empty_update
    receive_notifications 'Single'
    updated_page_as users(:red), 1.day.ago
    mail = mailer_class.deliver_updates_for page, to: [@user]
    assert_not mailer_class.deliveries.present?
  end

  def test_send_simple_update
    receive_notifications 'Single'
    updated_page_as users(:green), 5.minutes.ago
    updated_page_as users(:red), 1.minute.ago
    mail = mailer_class.deliver_updates_for(page, to: [@user]).first
    assert mailer_class.deliveries.present?
    assert_includes mail.body, 'Red! has modified the page title'
    assert_includes mail.body, 'Green! has modified the page title'
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_send_simple_update_comment_and_wiki
    receive_notifications 'Single'
    added_comment_as users(:red), 1.minute.ago
    updated_wiki_as users(:red), 1.minute.ago
    mail = mailer_class.deliver_updates_for(page, to: [@user]).first
    assert mailer_class.deliveries.present?
    assert_includes mail.body, 'Red! added a comment'
    assert_includes mail.body, 'Red! has updated the page content'
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_send_paranoid_update
    with_paranoid_emails
    receive_notifications 'Single'
    updated_page_as users(:red), 1.minute.ago
    mail = mailer_class.deliver_updates_for(page, to: [@user]).first
    assert mailer_class.deliveries.present?
    assert_not_includes mail.body, 'Red! has modified the page title'
    assert_includes mail.body, 'A page that you are watching has been modified'
    assert mailer_class.deliveries.first.encrypted?
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
    page[:updated_by_id] = user.id
    page.save
    Page::History::ChangeTitle.create user: user, page: page, created_at: time
  end

  def added_comment_as(user, time = 1.day.ago)
    post = FactoryBot.create(:post)
    page.add_post(user, body: post)
    page[:updated_by_id] = user.id
    page.save
    assert page.discussion.present?
    Page::History::AddComment.create user: user, page: page, created_at: time, item: post
  end

  def updated_wiki_as(user, time = 1.day.ago)
    page[:updated_by_id] = user.id
    page.save
    assert page.discussion.present?
    Page::History::UpdatedContent.create user: user, page: page, created_at: time
  end

  def page
    @page ||= pages(:blue_page)
  end
end
