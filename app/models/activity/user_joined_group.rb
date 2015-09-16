class Activity::UserJoinedGroup < Activity

  validates_format_of :subject_type, with: /User/
  validates_format_of :item_type, with: /Group/
  validates_presence_of :subject_id
  validates_presence_of :item_id

  alias_attr :user,  :subject
  alias_attr :group, :item

  before_create :set_access
  def set_access
    if user.has_access?(:see_groups, :public) and group.has_access?(:see_members, :public)
      self.access = Activity::PUBLIC
    end
  end


  def description(view=nil)
    I18n.t(:activity_user_joined_group,
              user: user_span(:user),
              group_type: group_class(:group),
              group: group_span(:group))
  end

  def icon
    'membership_add'
  end

end
