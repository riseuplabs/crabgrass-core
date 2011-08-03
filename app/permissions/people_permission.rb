module PeoplePermission

  protected

  def may_list_friends?
    current_user.may?(:see_contacts, @user)
  end

  def may_list_groups?
    current_user.may?(:see_groups, @user)
  end

  def may_request_contact?
    current_user.may?(:request_contact, @user)
  end

end
