class Tracking::UserParticipationObserver < ActiveRecord::Observer
  observe :user_participation

  def after_save(up)
    params = { user: User.current, page: up.page, item: up.user }
    PageHistory::StartWatching.create(params)         if up.start_watching?
    PageHistory::StopWatching.create(params)          if up.stop_watching?
    PageHistory::AddStar.create(params)               if up.star_added?
    PageHistory::RemoveStar.create(params)            if up.star_removed?
  end

  def after_destroy(up)
    params = { user: User.current, page: up.page, item: up.user }
    PageHistory::RevokedUserAccess.create(params)
  end

end
