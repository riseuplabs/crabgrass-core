class Tracking::GroupParticipationObserver < ActiveRecord::Observer
  observe :group_participation

  def after_destroy(gp)
    PageHistory::RevokedGroupAccess.create user: User.current,
      page: gp.page,
      item: gp.group
  end

end
