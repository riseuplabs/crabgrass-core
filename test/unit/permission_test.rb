require File.dirname(__FILE__) + '/test_helper'

class PermissionTest < ActiveSupport::TestCase

  fixtures :all

  def test_group_permissions_with_committees
    user = User.make
    group = Group.make_owned_by(:user => user)
    group.add_user! user
    invisible = Group.make
    invisible.revoke!(:public, :view)

    assert user.may?(:admin, group), "should admin group i'm in"
    assert !user.may?(:view, invisible), "should not view group i'm not in."

    committee = Committee.make_for :group => group
    user.update_membership_cache
    assert user.may?(:admin, committee), "should admin committee of my group."
    council = Council.make_for :group => group
    group.reload
    committee.reload
    user.clear_access_cache
    assert !user.may?(:admin, committee), "should not admin committee of group with council."
    assert !user.may?(:admin, group)
    assert user.may?(:view, committee)
    assert user.may?(:view, group)

    council.add_user! user
    group.reload
    committee.reload
    user.clear_access_cache

    assert user.may?(:admin, committee)
    assert user.may?(:admin, group)

    invisible.grant!(:public, [:view, :pester])
    user.clear_access_cache
    invisible.reload
    assert user.may?(:pester, invisible)
    assert !user.may?(:admin, invisible)

    correct_visible_groups = Group.find(:all, :conditions => 'type IS NULL').select do |g|
      user.may?(:view,g)
    end
    visible_groups = Group.access_by(user).allows(:view).only_groups.find(:all)

    correct_names = correct_visible_groups.collect{|g|g.name}.sort
    names         = visible_groups.collect{|g|g.name}.sort

    assert_equal  correct_names, names
  end

  def test_find_committee
    user = users(:red)

    correct_visible_groups = Committee.find(:all).select do |g|
      user.may?(:view,g)
    end
    visible_groups = Committee.access_by(user).allows(:view).find(:all)

    correct_names = correct_visible_groups.collect{|g|g.name}.sort
    names         = visible_groups.collect{|g|g.name}.sort

    assert_equal  correct_names, names
  end
end
