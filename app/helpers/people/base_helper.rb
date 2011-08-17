module People::BaseHelper


  #
  # the link to request contact or remove contact.
  # for viewing our own profile, this becomes an edit link.
  #
  def profile_contact_link
    if current_user == @user
      link_to :edit.t, edit_me_profile_path, :icon => 'pencil'
    elsif current_user.friend_of?(@user)
      link_to :remove_friend_link.t, person_friend_request_path(@user), :method => :delete
    elsif pending_friend_request(:from => current_user, :to => @user)
      link_to :request_pending.t(:request => :request_to_friend.t), me_requests_path, :icon => 'clock'
    elsif may_request_contact?
      link_to_modal :request_friend_link.t, :url => new_person_friend_request_path(@user), :icon => 'plus'
    end
  end

end
