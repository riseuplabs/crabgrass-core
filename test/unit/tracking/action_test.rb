require 'test_helper'

class Tracking::ActionTest < ActiveSupport::TestCase
  def test_class_lookup
    Activity::Friend.expects(:create!)
    Tracking::Action.track :create_friendship
  end

  def test_key_seed
    Activity::Friend.expects(:create!).with(has_key(:key))
    Tracking::Action.track :create_friendship
  end

  def test_hand_over_args
    Activity::Friend.expects(:create!).with(has_key(:user))
    Tracking::Action.track :create_friendship, user: :dummy
  end

  def test_filter_args
    Activity::Friend.expects(:create!).with(Not(has_key(:dummy)))
    Tracking::Action.track :create_friendship, dummy: :user
  end

  def test_create_multiple_records
    Activity::GroupCreated.expects(:create!)
    Activity::UserCreatedGroup.expects(:create!)
    Tracking::Action.track :create_group
  end
end
