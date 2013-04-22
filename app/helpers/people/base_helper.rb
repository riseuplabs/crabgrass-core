module People::BaseHelper


  #
  # the link to request contact or remove contact.
  # for viewing our own profile, this becomes an edit link.
  #
  def profile_contact_link
    return if current_user.is_a? UnauthenticatedUser

    if current_user == @user
      link_to :edit.t, edit_me_profile_path, :icon => 'pencil'
    elsif current_user.friend_of?(@user)
      link_to :remove_friend_link.t,
        person_friend_request_path(@user),
        :method => :delete,
        :confirm => :friend_remove_confirmation.t(:user => @user.name)
    elsif req = RequestToFriend.existing(:from => current_user, :to => @user)
      link_to :request_pending.t(:request => :request_to_friend.t.capitalize), me_request_path(req), :icon => 'clock'
    elsif may_request_contact?
      link_to_modal :request_friend_link.t, :url => new_person_friend_request_path(@user), :icon => 'plus'
    end
  end

end
