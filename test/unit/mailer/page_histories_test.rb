require 'test_helper'

class Mailer::PageHistoriesTest < ActionMailer::TestCase

  def setup
    @user = users(:blue)
    @user = profiles(:public_profile_for_blue).user
    @user.profiles.first.update_attribute(:encrypt, true)
    key = <<-END
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v2

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
j1Rx6t+EEw==
=5G6T
-----END PGP PUBLIC KEY BLOCK-----
END

    ProfileCryptKey.create(profile_id: 11, key: key)
    @user.reload
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
    assert_includes mail.body, 'Red! has modified the page title'
    assert Mail::TestMailer.deliveries.first.encrypted?
  end

  def test_send_paranoid_digest
    with_paranoid_emails
    receive_notifications 'Digest'
    updated_page_as users(:red)
    mail = mailer_class.deliver_digests.first
    assert ActionMailer::Base.deliveries.present?
    assert_includes mail.body, 'A page that you are watching has been modified'
    assert_not_includes mail.body, 'Red! has modified the page title'
    assert Mail::TestMailer.deliveries.first.encrypted?
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
    assert_includes mail.body, 'Red! has modified the page title'
    assert_includes mail.body, 'Green! has modified the page title'
    assert Mail::TestMailer.deliveries.first.encrypted?
  end

  def test_send_simple_update_comment_and_wiki
    receive_notifications 'Single'
    added_comment_as users(:red), 1.minute.ago
    updated_wiki_as users(:red), 1.minute.ago
    mail = mailer_class.deliver_updates_for(page, to: [@user]).first
    assert ActionMailer::Base.deliveries.present?
    assert_includes mail.body, 'Red! added a comment'
    assert_includes mail.body, 'Red! has updated the page content'
    assert Mail::TestMailer.deliveries.first.encrypted?
  end

  def test_send_paranoid_update
    with_paranoid_emails
    receive_notifications 'Single'
    updated_page_as users(:red), 1.minute.ago
    mail = mailer_class.deliver_updates_for(page, to: [@user]).first
    assert ActionMailer::Base.deliveries.present?
    assert_not_includes mail.body, 'Red! has modified the page title'
    assert_includes mail.body, 'A page that you are watching has been modified'
    assert Mail::TestMailer.deliveries.first.encrypted?
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
    Page::History::ChangeTitle.create user: user, page: page, created_at: time
  end

  def added_comment_as(user, time = 1.day.ago)
    post = FactoryBot.create(:post) 
    page.add_post(user, body: post)
    page.updated_by user
    page.save
    assert page.discussion.present?
    Page::History::AddComment.create user: user, page: page, created_at: time, item: post
  end 
  
  def updated_wiki_as(user, time = 1.day.ago)
    page.updated_by user
    page.save
    assert page.discussion.present?
    Page::History::UpdatedContent.create user: user, page: page, created_at: time
  end 


  def page
    @page ||= pages(:blue_page)
  end
end
