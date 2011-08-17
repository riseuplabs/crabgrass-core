class UnauthenticatedUser
  def login
   I18n.t(:anonymous)
  end
  alias :name :login
  alias :display_name :login

  def may?(access,thing)
    case thing
    when Page
      access == :view and thing.public?
    when Group
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

  def member_of?(group)
    false
  end

  def method_missing(method)
    raise PermissionDenied.new("Tried to access #{method} on an unauthorized user.")
  end

  # authenticated users are real, we are not.
  def real?
    false
  end

end
