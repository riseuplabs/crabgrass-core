class Tracking::GroupParticipationObserver < ActiveRecord::Observer
  observe :group_participation

  def after_save(gp)
    PageHistory::GrantGroupAccess.create user: User.current,
      page: gp.page,
      participation: gp
  end

  def after_destroy(gp)
    PageHistory::RevokedGroupAccess.create user: User.current,
      page: gp.page,
      item: gp.group
  end

end
