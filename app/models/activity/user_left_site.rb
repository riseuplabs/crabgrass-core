class Activity::UserLeftSite < Activity::UserLeftGroup
  def description(view=nil)
    I18n.t(:activity_user_left_site,
         user: user_span(:user),
         group: group_span(:group))
  end
end
