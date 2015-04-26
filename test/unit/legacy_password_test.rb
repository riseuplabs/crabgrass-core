require_relative 'test_helper'
require 'digest/sha1'

# has_secure_password is fairly simple but we also need to support
# old passwords.
# We wrap them in a bcrypt hash to make them more robust.
# This test is for all of that.

class LegacyPasswordTest < ActiveSupport::TestCase

  def test_old_password_encryption
    old_password = 'my dear old password'
    user = User.new login: 'long_time_no_see',
      password: old_password
    # create old sha1 digest
    user.send :use_legacy_password_fields!
    assert user.salt.present?
    assert_equal Digest::SHA1.hexdigest("--#{user.salt}--#{user.password}--"),
      user.crypted_password
  end

  def test_bcrypt_wrapper_for_old_password
    user = user_with_legacy_password
    old_salt = user.salt
    old_password = user.password

    user.bcrypt_legacy_password_hash

    assert user.legacy_password?
    # kept old salt
    assert_equal old_salt, user.salt
    # cleared the old password hash
    assert_nil user.crypted_password
    # and still allows to authenticate with old password
    assert_equal user, user.authenticate(old_password)
  end

  # if you know the old_password for example during login you can migrate it
  def test_migrate_old_wrapped_password
    user = user_with_legacy_password
    old_password = user.password
    user.bcrypt_legacy_password_hash

    user.upgrade_password(old_password)

    assert_equal user, user.authenticate(old_password)
    assert !user.legacy_password?
  end

  protected

  def user_with_legacy_password
    FactoryGirl.build(:user).tap do |user|
      user.send :use_legacy_password_fields!
    end
  end
end
