module Page::ParticipationAccess

  def access_sym
    ACCESS_TO_SYM[self.access]
  end

  # can only be used to increase access.
  # because access is only increased, you cannot remove access with grant_access.
  def grant_access=(value)
    value = ACCESS[value] if ACCESS.has_key?(value)
    return if value.nil?
    current_access = read_attribute(:access) || 100
    if value < current_access
      write_attribute(:access, value)
    end
  end

  # sets the access level to be value, regardless of what it was before.
  # if value is nil, no change is made. If value is :none, then access is removed.
  def access=(value)
    return if value.nil?
    value = ACCESS[value] if ACCESS.has_key?(value)
    write_attribute(:access, value)
  end

  def grants_access?(perm)
    asked_access_level = ACCESS[perm] || ACCESS[:view]
    return false unless self.access
    self.access <= asked_access_level
  end

end
