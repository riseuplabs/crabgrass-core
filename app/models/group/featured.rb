module Group::Featured
  extend ActiveSupport::Concern

  included do
    has_many :featured_pages,
             -> { where ['`group_participations`.static = ?', true] },
             through: :participations,
             source: :page
  end

end

#
# It looks like this is not included right now. But then again we don't allow
# featuring pages right now anyway.
#
module Group::Participation::Featured
  extend ActiveSupport::Concern

  module ClassMethods
    def featured
      where(static: true)
    end
  end

  def feature!
    # find and increment the higest sibling position
    position = group.participations.maximum(:featured_position).to_i + 1
    update_attributes!(static: true, featured_position: position)
  end

  def unfeature!
    update_attributes!(static: false, featured_position: nil)
  end

end
