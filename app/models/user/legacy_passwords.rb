#
# User Extension for Legacy Passwords
#
# has_secure_password uses bcrypt which is far better at hashing passwords
# than sha1 which we used before crabgrass 0.6.1.
#
# In order to profit from the security gains of bcrypt without waiting for
# all users to login again so we can encrypt their plaintext password we use
# bcrypt(sha1(password, salt)) as an intermediate step. This allows us to
# simply bcrypt all existing hashes. We obviously need to keep the old salt.
#
# When a user logs in we calculate the old hash like before and then feed it to
# the password comparison of has_secure_password.
# If the password worked we also rehash it with plain bcrypt and remove the old
# salt from the database. This way we can tell how a password was hashed by
# looking at the salt of the record.
#
# Once all users have logged in or their accounts have expired we can remove
# this module. If you setup a fresh server with crabgrass >= 0.6.1 you can
# remove it as well.

require 'digest/sha1'
module User::LegacyPasswords
  extend ActiveSupport::Concern

  module ClassMethods
    def authenticate(login, passwd)
      super.tap do |user|
        user.upgrade_password(passwd) if user && user.legacy_password?
      end
    end

    def legacy_hash(passwd, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{passwd}--")
    end
  end

  def authenticate(passwd)
    if legacy_password?
      super(legacy_hash(passwd))
    else
      super
    end
  end

  def password=(new_passwd)
    fresh_password!
    super
  end

  # Migrate the user to plain has_secure_password if they still use the
  # legacy password hash.
  # When you have the old password just set it as the new one.
  # has_secure_password will take care of it.
  def upgrade_password(passwd)
    self.password = passwd
  end

  def legacy_password?
    salt.present?
  end

  # migrate old sha1 password to bcrypt(sha1)
  def bcrypt_legacy_password_hash
    # do not overwrite new password digests
    return if password_digest.present?
    return if salt.blank? || crypted_password.blank?
    # create a bcrypt digest of the old crypted_password keeping the salt
    # rubocop:disable Style/ParallelAssignment
    self.password, self.salt = crypted_password, salt
    # rubocop:enable Style/ParallelAssignment
    raise 'Could not create bcrypt digest' unless password_digest
    self.crypted_password = nil
    save if persisted?
  end

  def legacy_hash(passwd)
    self.class.legacy_hash(passwd, salt)
  end

  protected

  def fresh_password!
    self.salt = nil
  end

  # We use this to test compatibility with old passwords.
  def use_legacy_password_fields!
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now}--#{login}--")
    self.crypted_password = legacy_hash(password)
    self.password_digest = nil
  end
end
