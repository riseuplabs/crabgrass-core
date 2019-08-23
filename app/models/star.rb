class Star < ApplicationRecord
  belongs_to :user, inverse_of: :stars
  belongs_to :starred, polymorphic: true, counter_cache: true

  validates :starred_id, presence: true
  validates :starred_type, presence: true
  validates :user_id, presence: true
  validate :one_star_per_user_only

  protected

  def one_star_per_user_only
    if starred.stars.exists?(user_id: user_id)
      errors.add(starred_type, 'has already been starred')
    end
  end
end
