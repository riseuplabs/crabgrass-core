require 'test_helper'

class Mailer::DailyDigestTest <  ActionMailer::TestCase
  fixtures :all

  def setup
    @user = users(:blue)
    @user.update_attributes receive_notifications: 'Digest'
  end

  def test_wont_send_empty_mails
    Mailer::DailyDigest.deliver_all
    assert ActionMailer::Base.deliveries.empty?
  end

  def test_send_simple_digest
    watch_page
    updated_page_as users(:red)
    mail = Mailer::DailyDigest.deliver_all.first
    assert ActionMailer::Base.deliveries.present?
    assert_includes mail.body, "Red! has modified the page title"
  end

  protected

  def watch_page
    page.user_participations.where(user_id: @user).create watch: true
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
