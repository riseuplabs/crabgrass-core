module User::Participation::Starring
  extend ActiveSupport::Concern

  included do
    after_save :update_stars
  end

  def update_stars
    if page_id and self.star_changed?
      page.update_star_count
    end
  end

end
