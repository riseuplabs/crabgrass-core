#
# a UserParticipation holds the data representing a user's
# relationship with a particular page.
#
# fields:
# access, :integer      -- enum which determines page access. see 00-constants.rb
# viewed_at, :datetime  -- last visit
# changed_at, :datetime -- last modification by user
# watch, :boolean       -- is the user watching page for changes?
# star, :boolean        -- has the user starred this page?
# resolved, :boolean    -- the user's involvement with this node has been resolved.
# viewed, :boolean      -- the user has seen the lastest version
# attend, :boolean      -- the user will attend event
#

class User::Participation < ActiveRecord::Base

  include Common::ParticipationAccess

  belongs_to :page, inverse_of: :user_participations
  belongs_to :user, inverse_of: :participations

  validates :page, presence: true
  validates :user, presence: true

  before_create :clear_tag_cache
  after_destroy :clear_tag_cache

  # use this for counting stars :)
  include Starring
  include History

  # maybe later use this to replace all the notification stuff
  #  include ParticipationExtension::Subscribe

  def entity; user; end
  def group?; false;  end
  def user? ; true; end

  protected

  def clear_tag_cache
    user.clear_tag_cache
  end

end

