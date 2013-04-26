require_relative 'test_helper'

class GroupTest < ActiveSupport::TestCase


  def test_can_revoke_edit
    group = Group.create :name => 'group_with_council'
    council = Council.new(:name => 'council')
    group.add_council!(council)
    group.revoke_access! group => :edit
    group.reload
    assert !group.has_access?(:edit, group)
    assert group.has_access?(:edit, council)
  end

end
