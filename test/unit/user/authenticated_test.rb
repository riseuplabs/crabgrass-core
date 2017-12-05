require 'test_helper'

class User::AuthenticatedTest < ActiveSupport::TestCase
  def test_last_seen
    quentin = create_user(login: 'Tarantino')
    last_seen_at = quentin.last_seen_at
    quentin.seen!
    assert_not_equal quentin.last_seen_at.to_f, last_seen_at.to_f
    last_seen_at = quentin.last_seen_at
    quentin.seen!
    assert_equal quentin.last_seen_at.to_f, last_seen_at.to_f
  end

  def test_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, user.errors.full_messages.join(', ')
    end
  end

  def test_require_login
    assert_no_difference 'User.count' do
      u = create_user(login: nil)
      assert u.errors[:login]
    end
  end

  def test_require_password
    assert_no_difference 'User.count' do
      u = create_user(password: nil)
      assert u.errors[:password]
    end
  end

  def test_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(password_confirmation: '')
      assert u.errors[:password_confirmation]
    end
  end

  def test_reset_password
    pwd = 'new password'
    user = users(:quentin)
    user.update_attributes password: pwd,
                           password_confirmation: pwd
    assert user.save
    assert_equal users(:quentin), User.authenticate('quentin', pwd)
  end

  def test_change_login_without_password_rehash
    user = users(:quentin)
    user.update_attributes(login: 'quentin2')
    assert user.save, user.errors.full_messages.join(', ')
    assert_equal 'quentin2', user.login
    assert_equal users(:quentin), User.authenticate('quentin2', 'quentin')
  end

  def test_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin', 'quentin')
  end

  def test_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  protected

  # just like User.create this will return the user even if it's invalid
  def create_user(attrs = {})
    FactoryBot.build(:user, attrs).tap(&:save)
  end
end
