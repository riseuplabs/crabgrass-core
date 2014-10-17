module LastVisitHelper

  def last_visit
    # do not mark anything as new if logged out
    return Time.now unless logged_in?
    if @page
      @page.user_participations.where(user_id: current_user).first.viewed_at
    elsif @group
      @group.memberships.where(user_id: current_user).first.visited_at
    end
  end
end
