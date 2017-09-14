class Activity::UserJoinedSite < Activity::UserJoinedGroup
  def description(_view = nil)
    I18n.t(:activity_user_joined_site,
           user: user_span(:user),
           group: group_span(:group))
  end
end
