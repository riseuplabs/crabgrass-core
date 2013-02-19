class Tracking::UserParticipationObserver < ActiveRecord::Observer
  observe :user_participation

  def after_save(up)
    return unless User.current
    PageHistory::GrantUserFullAccess.create!(:user => User.current, :page => up.page, :object => up.user)   if up.granted_user_full_access?
    PageHistory::GrantUserWriteAccess.create!(:user => User.current, :page => up.page, :object => up.user)  if up.granted_user_write_access?
    PageHistory::GrantUserReadAccess.create!(:user => User.current, :page => up.page, :object => up.user)   if up.granted_user_read_access?
    PageHistory::StartWatching.create!(:user => User.current, :page => up.page)                             if up.start_watching?
    PageHistory::StopWatching.create!(:user => User.current, :page => up.page)                              if up.stop_watching?
    PageHistory::AddStar.create!(:user => User.current, :page => up.page)                                   if up.star_added?
    PageHistory::RemoveStar.create!(:user => User.current, :page => up.page)                                if up.star_removed?
  end

  def after_destroy(up)
    return unless User.current
    PageHistory::RevokedUserAccess.create!(:user => User.current, :page => up.page, :object => up.user)
  end

end
