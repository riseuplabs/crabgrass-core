require 'test_helper'

class Mailer::PgpSignTest < ActionMailer::TestCase

  def setup
    @user = users(:blue)
    add_pgp_key
    watch_page
    ActionMailer::Base.default_url_options = {:host => 'localhost:3000'}
    mailer_class.deliveries = nil
  end

  def test_send_signed_digest
    receive_notifications 'Digest'
    updated_page_as users(:red)
    mailer_class.deliver_digests
    mail = mailer_class.deliveries.first
    if ENV['GPGKEY']
      assert mail.encrypted?
      decrypted_mail = mail.decrypt(verify: true)
      assert_equal 'robot@riseup.net', decrypted_mail['sign-as'].value
    end
  end

  protected

  def add_pgp_key
    if ENV['GPGKEY']
      begin
        key = File.read(ENV['GPGKEY'])
        PgpKey.create(user_id: 4, key: key)
        @user.reload
      rescue => e
        puts 'Error: ' + e.message
      end
    end
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

  def page
    @page ||= pages(:blue_page)
  end
end
