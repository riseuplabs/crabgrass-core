class GroupObserver < ActiveRecord::Observer

  def after_create(group)
    key = rand(Time.now.to_i)
    GroupCreatedActivity.create!(group: group, user: group.created_by, key: key)

    if group.created_by
      UserCreatedGroupActivity.create!(group: group, user: group.created_by, key: key)
    end

    if User.current && User.current.real?
      if !group.is_a?(Network) or (group.is_a?(Network) and !User.current.may?(:admin, group))
        group.add_user!(User.current)
      end
    end
  end

end

