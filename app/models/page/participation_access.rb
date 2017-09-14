module Page::ParticipationAccess
  def access_sym
    ACCESS_TO_SYM[access]
  end

  # can only be used to increase access.
  # because access is only increased, you cannot remove access with grant_access.
  def grant_access=(value)
    value = ACCESS[value] if ACCESS.key?(value)
    return if value.nil?
    current_access = read_attribute(:access) || 100
    write_attribute(:access, value) if value < current_access
  end

  # sets the access level to be value, regardless of what it was before.
  # if value is nil, no change is made. If value is :none, then access is removed.
  def access=(value)
    return if value.nil?
    value = ACCESS[value] if ACCESS.key?(value)
    write_attribute(:access, value)
  end

  def grants_access?(perm)
    asked_access_level = ACCESS[perm] || ACCESS[:view]
    return false unless access
    access <= asked_access_level
  end
end
