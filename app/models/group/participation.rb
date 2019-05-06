class Group::Participation < ApplicationRecord
  include Page::ParticipationAccess

  belongs_to :page, inverse_of: :group_participations
  belongs_to :group, inverse_of: :participations

  validates :page, presence: true
  validates :group, presence: true

  def entity
    group
  end

  def group?
    true
  end

  def user?
    false
  end
end
