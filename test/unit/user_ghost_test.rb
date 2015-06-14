require 'test_helper'

class UserGhostTest < ActiveSupport::TestCase
  fixtures :users

  #
  # Ghosts do not require a login or a password
  #
  def test_valid_without_attributes
    ghost = UserGhost.new
    assert ghost.valid?, ghost.errors.full_messages.join(', ')
  end

  def test_retire_user
    user = users(:blue)
    user = user.ghostify!
    user.retire!
    user.reload
    user.attributes.except("id", "type", "login", "display_name").each do |k, v|
      assert_blank v, "expected #{k} to be cleared"
    end
    assert_equal "Blue!", user.display_name
    assert_equal "blue", user.name
    assert_equal [], user.keys
  end

  def test_ghostified_user
    user = users(:blue)
    ghost = user.ghostify!
    assert_equal UserGhost, ghost.class
    assert ghost.retire!, ghost.errors.full_messages.join(', ')
  end

  def test_ghost_user
    user = users(:blue)
    ghost = user.ghostify!
    assert ghost.save, ghost.errors.full_messages.join(', ')
    ghost = User.find(ghost.id)
    assert ghost.retire!, ghost.errors.full_messages.join(', ')
  end
end
