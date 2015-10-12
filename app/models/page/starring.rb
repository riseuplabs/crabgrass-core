module Page::Starring
  extend ActiveSupport::Concern

  # Helps with getting and setting static content
  module ClassMethods

    # finds the pages with the most stars
    # use options[:at_least] to pass the number of stars required
    # use options[:limit] to limitate them to a number of Integer
    # use options[:order] to override default order DESC
    def find_by_stars options={}
      limit = options[:limit] || nil
      order = options[:order] || "stars_count DESC"
      at_least = options[:at_least] || 0
      find :all, order: order, limit: limit, conditions: ["stars_count >= ?", at_least]
    end

    #
    # I hope this no one ever want to call this code. It would be really expensive.
    # Seems unused. I am commenting it out.
    #
    #def update_all_stars
    #  self.find(:all).each do |page|
    #    correct_stars = page.get_stars
    #    page.update_attribute(:stars_count, correct_stars) if correct_stars != page.stars
    #  end
    #end

  end


  # updates the star count for this page.
  # called in after_save of user_participation when :star is changed.
  def update_star_count
    new_count = self.user_participations.count(:all, conditions: {star: true})
    if new_count != self.stars_count
      self.update_attribute(:stars_count, new_count)
    end
  end

end

