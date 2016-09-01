class User::Token < ActiveRecord::Base
  self.table_name = 'tokens'

  belongs_to :user

  @@validity_time = 1.day

  before_create :generate_value

  def self.expired
    where ["created_at < ?", Time.now - @@validity_time]
  end

  def self.active
    where ["created_at >= ?", Time.now - @@validity_time]
  end

  def self.to_recover
    where action: 'recovery'
  end

  def self.find_by_param(value)
    find_by_value(value)
  end

  # Delete all expired tokens
  def self.destroy_expired
    expired.delete_all
  end

  # Return true if token has expired
  def expired?
    return Time.now > self.created_at + @@validity_time
  end

  def to_s; value; end
  alias_method :to_param, :to_s

  protected
  def generate_value
    self.value = self.class.generate_token_value
  end

  private
  def self.generate_token_value
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    token_value = ''
    20.times { |i| token_value << chars[rand(chars.size-1)] }
    token_value
  end
end
