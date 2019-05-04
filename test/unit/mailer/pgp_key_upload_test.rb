require 'test_helper'

class Mailer::PgpKeyUploadTest < ActionMailer::TestCase

# we want to make sure not to send unencrypted emails if a
# key is invalid or expired

  def setup
    ActionMailer::Base.default_url_options = {:host => 'localhost:3000'}
    mailer_class.deliveries = nil
  end

  def test_forever_key
    user = users(:blue)
    mail = mailer_class.key_uploaded_mail(user).deliver_now
    assert_includes mail.body, 'You just uploaded a new key'
    assert mailer_class.deliveries.present?
    assert mailer_class.deliveries.first.encrypted?
  end

  def test_valid_to_2050_key
    user = users(:dolphin)
    mail = mailer_class.key_uploaded_mail(user).deliver_now
    assert_includes mail.body, 'You just uploaded a new key'
    assert mailer_class.deliveries.present?
    assert mailer_class.deliveries.first.encrypted?
  end

  # only valid keys can be uploaded, but a key might expire
  def test_expired_key
    user = users(:green)
    assert_raises Mail::Gpg::MissingKeysError do
      mail = mailer_class.key_uploaded_mail(user).deliver_now
    end
  end

  # would not happen in real life, because it is not possible to
  # upload a broken key
  def test_broken_key
    user = users(:red)
    assert_raises Mail::Gpg::MissingKeysError do
      mail = mailer_class.key_uploaded_mail(user).deliver_now
    end
  end

  protected

  def mailer_class
    Mailer::PgpKeyUploadMailer
  end

  def receive_notifications(type)
    @user.update_attributes receive_notifications: type
  end

end
