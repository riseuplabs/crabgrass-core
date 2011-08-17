module Groups::HomePermission

  protected

  def may_show_groups_home?(group = @group)
    current_user.may? :view, group
  end

end
