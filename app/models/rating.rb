#
# Adapted from acts_as_rateable
#

class Rating < ActiveRecord::Base
  belongs_to :rateable, :polymorphic => true

  belongs_to :user

  # Helper class method to lookup all ratings assigned
  # to all rateable types for a given user.
  def self.find_ratings_by_user(user)
    by_user(user).order('created_at DESC')
  end

  def self.with_rating(rating)
    where(rating: rating)
  end

  def self.by_user(user)
    where(user_id: user)
  end
end

