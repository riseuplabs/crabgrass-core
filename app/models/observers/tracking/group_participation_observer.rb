class Tracking::GroupParticipationObserver < ActiveRecord::Observer
  observe :group_participation

  def after_save(gp)
    return unless User.current
    PageHistory::GrantGroupFullAccess.create!(:user => User.current, :page => gp.page, :object => gp.group)  if gp.granted_group_full_access?
    PageHistory::GrantGroupWriteAccess.create!(:user => User.current, :page => gp.page, :object => gp.group) if gp.granted_group_write_access?
    PageHistory::GrantGroupReadAccess.create!(:user => User.current, :page => gp.page, :object => gp.group)  if gp.granted_group_read_access?
  end

  def after_destroy(gp)
    return unless User.current
    PageHistory::RevokedGroupAccess.create!(:user => User.current, :page => gp.page, :object => gp.group)
  end

end
