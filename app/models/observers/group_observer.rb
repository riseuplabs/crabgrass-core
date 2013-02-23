class GroupObserver < ActiveRecord::Observer

  def before_destroy(group)
    key = rand(Time.now)
    group.users_before_destroy.each do |recipient|
      GroupDestroyedActivity.create!(:groupname => group.name, :recipient => recipient, :destroyed_by => group.destroyed_by, :key => key)
      Mailer.group_destroyed_notification(recipient, group).deliver
    end
  end

  def after_create(group)
    key = rand(Time.now)
    GroupCreatedActivity.create!(:group => group, :user => group.created_by, :key => key)

    if group.created_by
      UserCreatedGroupActivity.create!(:group => group, :user => group.created_by, :key => key)
    end

    if User.current && User.current.real?
      if !group.is_a?(Network) or (group.is_a?(Network) and !User.current.may?(:admin, group))
        group.add_user!(User.current)
      end
    end
  end

end

