require 'test_helper'

class User::GhostTest < ActiveSupport::TestCase
  fixtures :users

  # you are not supposed to create ghosts from scratch.
  # existing users are turned into ghosts with ghostify.
  def test_valid_without_attributes
    assert !User::Ghost.new.valid?
  end

  def test_retire_user
    user = users(:blue)
    user = user.ghostify!
    user.retire!
    user.reload
    user.attributes.except("id", "type", "login", "display_name").each do |k, v|
      assert v.blank?, "expected #{k} to be cleared"
    end
    assert_equal "Blue!", user.display_name
    assert_equal "blue", user.name
    assert_equal [], user.keys
  end

  def test_ghostified_user
    user = users(:blue)
    ghost = user.ghostify!
    assert_equal User::Ghost, ghost.class
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
