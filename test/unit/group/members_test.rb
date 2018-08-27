require 'test_helper'

class Group::MembersTest < ActiveSupport::TestCase
  # this is used when sharing with a group to only notify
  # the members which allow the current user to pester them
  #
  # This was broken because the assocation group.users sets a
  # select_value for the relation that is included with the
  # DISTINCT select of with_access.
  # We work around that by defining a custom with_access for the
  # association now.
  def test_pestering_all_members
    group = groups(:rainbow)
    users = group.users.with_access(public: :pester)
    users.each do |user|
      assert group.users.include? user
      assert user.access?(public: :pester)
    end
    group.users.each do |user|
      assert users.include?(user) || !user.access?(public: :pester)
    end
    assert_equal users.distinct, users
  end
end
