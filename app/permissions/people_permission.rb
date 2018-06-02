module PeoplePermission
  protected

  def may_request_contact?
    current_user.may?(:request_contact, @user) &&
      current_user != @user
  end
end
