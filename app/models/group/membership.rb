class Group::Membership < ApplicationRecord
  self.table_name = 'memberships'

  belongs_to :user
  belongs_to :group

  validates :user, presence: true
  validates :group, presence: true

  def self.alphabetized_by_user(letter)
    conditions = if letter == '#'
                   ['users.login REGEXP ?', '^[^a-z]']
                 elsif letter.present?
                   ['users.login LIKE ?', "#{letter}%"]
    end
    joins(:user)
      .order('users.login ASC')
      .select('memberships.*')
      .where(conditions)
  end

  alias entity user
  # this deals with users in contrast to federatings
  def user?
    true
  end
end
