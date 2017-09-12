module Page::Starring
  extend ActiveSupport::Concern

  # Helps with getting and setting static content
  module ClassMethods
    # finds the pages with the most stars
    # use options[:at_least] to pass the number of stars required
    # use options[:limit] to limitate them to a number of Integer
    # use options[:order] to override default order DESC
    def find_by_stars(options = {})
      where('stars_count >= ?', options[:at_least] || 0)
        .order(options[:order] || 'stars_count DESC')
        .limit(options[:limit] || nil)
    end
  end

  # updates the star count for this page.
  # called in after_save of user_participation when :star is changed.
  def update_star_count
    new_count = user_participations.where(star: true).count
    update_attribute(:stars_count, new_count) if new_count != stars_count
  end
end
