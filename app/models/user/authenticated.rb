# == Schema Information
# Schema version: 24
#
# Table name: users
#
#  id                        :integer(11)   not null, primary key
#  login                     :string(255)
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#  display_name              :string(255)
#  time_zone                 :string(255)
#  language                  :string(5)
#  avatar_id                 :integer(11)
#

module User::Authenticated
  extend ActiveSupport::Concern

  included do
    has_secure_password

    # the current site (set tmp on a per-request basis)
    attr_accessor :current_site

    validates :password, length: { minimum: 8, allow_blank: true }

    with_options unless: :ghost? do |alive|
      alive.validates :login, presence: true,
                              length: { within: 3..40 },
                              format: { with: /\A[a-z0-9]+([-_]*[a-z0-9]+){1,39}\z/ }

      # uniqueness is validated elsewhere
    end
  end

  module ClassMethods
    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def authenticate(login, password)
      find_by_login(login).try.authenticate(password)
    end

    # set to the currently logged in user.
    def current
      Thread.current[:user]
    end

    def current=(user)
      Thread.current[:user] = user
    end
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = SecureRandom.hex
    save(validate: false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(validate: false)
  end

  # authenticated users are real, unathenticated are unknown
  def real?
    true
  end

  def unknown?
    false
  end

  # Update last_seen_at if have passed 5 minutes from the last time
  def seen!
    now = Time.now.utc
    return unless last_seen_at.nil? || last_seen_at < now - 5.minutes
    update_column :last_seen_at, now
  end
end
