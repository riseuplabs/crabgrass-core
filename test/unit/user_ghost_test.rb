require 'test_helper'

class UserGhostTest < ActiveSupport::TestCase
  fixtures :users

  #
  # Ghosts do not require a login or a password
  #
  def test_valid_without_attributes
    assert UserGhost.new.valid?
  end

  def test_retire_user
    user = users(:blue)
    user = user.ghostify!
    user.retire!
    user.reload
    user.attributes.except("id", "type", "login", "display_name").each do |k, v|
      assert_nil v, "expected #{k} to be cleared"
    end
    assert_equal "Blue!", user.display_name
    assert_equal "blue", user.name
    assert_equal [], user.keys
  end
end
