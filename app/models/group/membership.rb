#
# user to group relationship
#
#  create_table "memberships", :force => true do |t|
#    t.integer  "group_id",     :limit => 11
#    t.integer  "user_id",      :limit => 11
#    t.datetime "created_at"
#    t.boolean  "admin",                      :default => false
#    t.datetime "visited_at"
#    t.integer  "total_visits", :limit => 11, :default => 0
#    t.string   "join_method"
#  end
#
#  add_index "memberships", ["group_id", "user_id"], :name => "gu"
#  add_index "memberships", ["user_id", "group_id"], :name => "ug"
#

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
