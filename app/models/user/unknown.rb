class User::Unknown
  def login
    :anonymous.t
  end
  alias name login
  alias display_name login

  def id
    nil
  end

  def cache_key
    'anonymous-1'
  end

  def may?(access, thing)
    # nothing but viewing for now.
    return false unless access == :view
    case thing
    when Group, User
      thing.has_access?(access, self)
    else
      false
    end
  end

  def access_codes
    [0]
  end

  def current_status
    ''
  end

  def friends
    User.none
  end

  def peers
    User.none
  end

  def groups
    Group.none
  end
  alias all_groups groups

  def member_of?(_group)
    false
  end

  def friend_of?(_user)
    false
  end

  def friend_ids
    []
  end

  def peer_ids
    []
  end

  def method_missing(method)
    raise PermissionDenied.new("Tried to access #{method} on an unauthorized user.")
  end

  # authenticated users are real, we are not.
  def real?
    false
  end

  def unknown?
    true
  end

  def time_zone
    Time.zone_default
  end
end
