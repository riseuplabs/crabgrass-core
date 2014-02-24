require_relative '../integration_test'

class VisibilityTest < IntegrationTest

  def test_hidden_is_visible_to_self
    as_a hidden_user do |me|
      visit "/#{me.login}"
      assert_landing_page(me)
    end
  end

  def test_not_visible_to_others
    as_a [friend_of(hidden_user), peer_of(hidden_user), user, visitor] do
      visit "/#{hidden_user.login}"
      assert_not_found
    end
  end

  def test_visible_to_friends_and_peers
    as_a [friend_of(user), peer_of(user)] do
      visit "/#{user.login}"
      assert_landing_page(user)
    end
  end

  def test_not_visible_to_strangers
    as_a [other_user, visitor] do
      visit "/#{user.login}"
      assert_not_found
    end
  end

  def test_not_found_looks_like_hidden
    as_a [user, visitor] do
      visit "/something-that-does-not-exist"
      assert_not_found
    end
  end

  def test_publicly_visible
    as_a [other_user, visitor] do
      visit "/#{public_user.login}"
      assert_landing_page(public_user)
    end
  end

end
