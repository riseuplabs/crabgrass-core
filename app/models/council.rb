class Council < Committee
  def add_user!(user)
    parent.clear_key_cache if parent
    super(user)
  end

  def remove_user!(user)
    parent.clear_key_cache if parent
    super(user)
  end
end
