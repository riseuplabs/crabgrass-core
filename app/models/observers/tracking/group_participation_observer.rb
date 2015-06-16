class Tracking::GroupParticipationObserver < ActiveRecord::Observer
  observe :group_participation

  def after_save(gp)
    params = { user: User.current, page: gp.page, item: gp.group , participation: gp}
    PageHistory::GrantGroupFullAccess.create(params)  if gp.granted_group_full_access?
    PageHistory::GrantGroupWriteAccess.create(params) if gp.granted_group_write_access?
    PageHistory::GrantGroupReadAccess.create(params)  if gp.granted_group_read_access?
  end

  def after_destroy(gp)
    PageHistory::RevokedGroupAccess.create(user: User.current, page: gp.page, item: gp.group)
  end

end
