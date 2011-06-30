module PeoplePermission

  protected

  def may_list_friends?
    current_user.may?(:see_contacts, @user)
  end

  def may_list_groups?
    current_user.may?(:see_groups, @user)
  end

end
