class GroupObserver < ActiveRecord::Observer

  def after_create(group)
    key = rand(Time.now.to_i)
    GroupCreatedActivity.create!(group: group, user: group.created_by, key: key)

    if group.created_by
      UserCreatedGroupActivity.create!(group: group, user: group.created_by, key: key)
    end

  end

end

