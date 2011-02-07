module UserParticipationExtension
  module Starring

    def self.included(base)
      base.class_eval do
        after_save :update_stars
      end
    end

    def update_stars
      if page_id and self.star_changed?
        page.update_star_count
      end
    end

  end
end
