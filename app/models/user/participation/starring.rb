module User::Participation::Starring
  extend ActiveSupport::Concern

  included do
    after_save :update_stars
  end

  def update_stars
    page.update_star_count if page_id and star_changed?
  end
end
