module UserParticipationExtension::PageHistory
  def start_watching?
    self.watch_changed? && self.watch == true
  end

  def stop_watching?
    self.watch_changed? && self.watch != true
  end

  def star_added?
    self.star_changed? && self.star == true
  end

  def star_removed?
    self.star_changed? && self.star != true
  end

  def cleared_user_access?
    self.access_changed? && self.access_sym == nil
  end
end
