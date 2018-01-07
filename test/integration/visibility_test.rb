require 'integration_test'

class VisibilityTest < IntegrationTest
  def test_hidden_is_visible_to_self
    as_a hidden_user do |me|
      visit "/#{me.login}"
      assert_profile_page(me)
    end
  end

  # regression test for #6757
  def test_hidden_user_can_see_own_pages
    as_a hidden_user do |me|
      visit '/me/pages'
      assert_content me.display_name
    end
  end

  def test_profile_not_visible_to_others
    as_a [friend_of(hidden_user), peer_of(hidden_user), user] do
      visit "/#{hidden_user.login}"
      assert_content "Private Profile"
    end
  end

  def test_send_messages_not_visible
    as_a  [friend_of(message_blocking_user), peer_of(message_blocking_user), user, other_user, visitor] do
      visit "/#{message_blocking_user.login}"
      assert_no_content "Send Message"
    end
  end

   def test_add_contact_not_visible
    as_a  [friend_of(contact_blocking_user), peer_of(contact_blocking_user), user, other_user, visitor] do
      visit "/#{contact_blocking_user.login}"
      assert_no_content "Add To My Contacts"
    end
  end

  def test_send_messages_add_contact_not_visible
    as_a  [friend_of(blocking_user), peer_of(blocking_user), user, other_user, visitor] do
      visit "/#{blocking_user.login}"
      assert_no_content "Send Message"
      assert_no_content "Add To My Contacts"
    end
  end

  def test_visible_to_friends_by_default
    as_a friend_of(user) do
      visit "/#{user.login}"
      assert_profile_page(user)
    end
  end

  def test_not_visible_to_peers_and_strangers
    as_a [peer_of(user), other_user] do
      visit "/#{user.login}"
      assert_content "Private Profile"
    end
  end

   def test_not_visible_to_external_visitors
    as_a visitor do
      visit "/#{user.login}"
      assert_not_found
    end
  end

  def test_visible_to_friends_and_peers
    user.grant_access! peers: :view
    as_a friend_of(user) do
      visit "/#{user.login}"
      assert_profile_page(user)
    end
  end

  def test_not_visible_to_strangers
    user.grant_access! peers: :view
    as_a other_user do
      visit "/#{user.login}"
      assert_content "Private Profile"
    end
  end

  def test_not_visible_to_external_visitors
    user.grant_access! peers: :view
    as_a visitor do
      visit "/#{user.login}"
      assert_not_found
    end
  end

  def test_not_found_looks_like_hidden
    as_a [user, visitor] do
      visit '/something-that-does-not-exist'
      assert_not_found
    end
  end

  def test_publicly_visible
    as_a [other_user, visitor] do
      visit "/#{public_user.login}"
      assert_profile_page(public_user)
    end
  end

  # regression test for #6755
  def test_new_group_not_found
    group
    as_a user do
      visit "/#{group.name}"
      assert_not_found
    end
  end
end
