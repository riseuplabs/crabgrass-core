class UnauthenticatedUser

  def login
    :anonymous.t
  end
  alias :name :login
  alias :display_name :login

  def cache_key
    "anonymous-1"
  end

  def may?(access,thing)
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
    ""
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
  alias_method :all_groups, :groups

  def member_of?(group)
    false
  end

  def friend_of?(user)
    false
  end

  def friend_ids; [] ; end
  def peer_ids;   [] ; end

  def method_missing(method)
    raise PermissionDenied.new("Tried to access #{method} on an unauthorized user.")
  end

  # authenticated users are real, we are not.
  def real?
    false
  end

  def time_zone
    Time.zone_default
  end

end
