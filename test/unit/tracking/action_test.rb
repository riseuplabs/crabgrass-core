require 'test_helper'

class Tracking::ActionTest < ActiveSupport::TestCase

  def test_class_lookup
    FriendActivity.expects(:create!)
    Tracking::Action.track :create_friendship
  end

  def test_key_seed
    FriendActivity.expects(:create!).with(has_key(:key))
    Tracking::Action.track :create_friendship
  end

  def test_hand_over_args
    FriendActivity.expects(:create!).with(has_key(:user))
    Tracking::Action.track :create_friendship, user: :dummy
  end

  def test_filter_args
    FriendActivity.expects(:create!).with(Not(has_key(:dummy)))
    Tracking::Action.track :create_friendship, dummy: :user
  end

  def test_create_multiple_records
    GroupCreatedActivity.expects(:create!)
    UserCreatedGroupActivity.expects(:create!)
    Tracking::Action.track :create_group
  end
end
