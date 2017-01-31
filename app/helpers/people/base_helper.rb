module People::BaseHelper


  #
  # the link to request contact or remove contact.
  # for viewing our own profile, this becomes an edit link.
  #
  def profile_contact_link
    return if current_user.unknown? || current_user == @user

    if current_user.friend_of?(@user)
      link_to :remove_friend_link.t,
        person_friend_request_path(@user),
        method: :delete,
        confirm: :friend_remove_confirmation.t(user: @user.name)
    elsif req = RequestToFriend.existing(from: current_user, to: @user)
      link_to :request_pending.t(request: :request_to_friend.t.capitalize), me_request_path(req), icon: 'clock'
    elsif may_request_contact?
      link_to_modal :request_friend_link.t, url: new_person_friend_request_path(@user), icon: 'plus'
    end
  end

  def profile_send_message_link
    if may_pester?
      link_to :send_message_link.t, me_discussion_posts_path(@user), icon: :page_message
    end
  end
end
