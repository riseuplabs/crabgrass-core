require 'test_helper'

class Tracking::ActionTest < ActiveSupport::TestCase
  def test_class_lookup
    expecting_creation_of Activity::Friend do
      Tracking::Action.track :create_friendship
    end
  end

  def test_args
    expecting_creation_of Activity::Friend, with: [:key, :user] do
      Tracking::Action.track :create_friendship, user: :dummy, dummy: :user
    end
  end

  def test_create_multiple_records
    expecting_creation_of Activity::GroupCreated do
      expecting_creation_of Activity::UserCreatedGroup do
        Tracking::Action.track :create_group
      end
    end
  end

  protected

  # okay... this is a bit too fancy. No idea how to simplify.
  # calling this makes klass expect create! to be called.
  #
  # with: keys of the hash expected to be handed to create!
  #       only checked if present
  def expecting_creation_of(klass, with: nil, &block)
    method_mock = Minitest::Mock.new
    method_mock.expect :call, nil do |args_hash|
      !with || with.sort == args_hash.keys.sort
    end
    klass.stub :create!, method_mock, &block
    method_mock.verify
  end
end
