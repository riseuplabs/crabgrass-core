module PeoplePermission

  protected

  def may_list_friends?
    current_user.may?(:see_contacts, @user) or current_user == @user
  end

  def may_list_groups?
    current_user.may?(:see_groups, @user) or current_user == @user
  end

  def may_request_contact?
    current_user.may?(:request_contact, @user)
  end

end
