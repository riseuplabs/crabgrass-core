require_relative 'test_helper'

class AuthenticatedUserTest < ActiveSupport::TestCase

  fixtures :users

  def test_last_seen
    quentin = create_user(:login => "Tarantino")
    last_seen_at = quentin.last_seen_at
    quentin.seen!
    assert_not_equal quentin.last_seen_at.to_f, last_seen_at.to_f
    last_seen_at = quentin.last_seen_at
    quentin.seen!
    assert_equal quentin.last_seen_at.to_f, last_seen_at.to_f
  end

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.join(', ')}"
    end
  end

  def test_should_require_login
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_reset_password
    pwd = "new password"
    user = users(:quentin)
    user.update_attributes :password => pwd,
      :password_confirmation => pwd
    user.save
    user.reload
    assert_equal pwd, user.password
    assert_equal 'quentin', user.login
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    user = users(:quentin)
    user.update_attributes(:login => 'quentin2')
    user.save
    user.reload
    assert_equal 'quentin', user.password
    assert_equal 'quentin2', user.login
    assert_equal users(:quentin), User.authenticate('quentin2', 'quentin')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin', 'quentin')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  protected
    def create_user(options = {})
      User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
