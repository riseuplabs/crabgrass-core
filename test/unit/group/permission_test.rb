require 'test_helper'

class Group::PermissionTest < ActiveSupport::TestCase
  def test_can_revoke_edit
    group = Group.create name: 'group_with_council'
    council = Group::Council.new(name: 'council')
    group.add_council!(council)
    group.revoke_access! group => :edit
    group.reload
    assert !group.has_access?(:edit, group)
    assert group.has_access?(:edit, council)
  end
end
