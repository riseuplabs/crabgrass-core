class Vote < ActiveRecord::Base
  validates_presence_of :votable_id

  belongs_to :possible
  belongs_to :user
  belongs_to :votable, polymorphic: :true

  def self.by_user(user)
    where(user_id: user)
  end

  def self.for_possible(possible)
    where(possible_id: possible)
  end

end
