module GroupParticipationExtension::PageHistory
  def cleared_group_access?
    self.access_changed? && self.access_sym == nil
  end
end
