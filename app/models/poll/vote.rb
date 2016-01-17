class Poll::Vote < ActiveRecord::Base
  self.table_name = 'votes'

  validates_presence_of :votable_id

  belongs_to :possible, class_name: 'Poll::Possible'
  belongs_to :user
  belongs_to :votable, polymorphic: :true

  def self.by_user(user)
    where(user_id: user)
  end

  def self.for_possible(possible)
    where(possible_id: possible)
  end

end
