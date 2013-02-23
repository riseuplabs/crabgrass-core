class Vote < ActiveRecord::Base
  validates_presence_of :votable_id

  belongs_to :possible
  belongs_to :user
  belongs_to :votable, :polymorphic => :true

  scope :by_user, lambda { |user|
    {:conditions => {:user_id => user.id}}
  }

  scope :for_possible, lambda { |possible|
    {:conditions => {:possible_id => possible.id}}
  }

end
