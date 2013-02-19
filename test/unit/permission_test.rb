require File.dirname(__FILE__) + '/test_helper'

class PermissionTest < ActiveSupport::TestCase
  fixtures :all

  #
  # This test uses user.clear_access_cache. This is needed after a structure change because the user object has
  # in-memory cached the previous results.
  #
  # Changing the org structure clears the cache in the db, but not in memory. This is typically OK in practice,
  # because after the org structure change the app does not do further permission checks. But for tests,
  # we need to manually fetch a new user object or call clear_access_cache.
  #
  def test_group_permissions_with_committee_and_council
    # create a group and user
    user = FactoryGirl.create(:user, :login => 'earth')
    group = FactoryGirl.create(:group, :name => 'planets')
    group.add_user! user
    assert user.may?(:admin, group), "should admin group i'm in"

    # add a committee
    committee = FactoryGirl.create(:committee)
    group.add_committee! committee

    assert user.may?(:admin, committee), "should admin committee of my group."

    # add a council
    council = FactoryGirl.create(:committee, :name => 'astrophysicists')
    group.add_council!(council)
    user.clear_access_cache
    assert !user.may?(:admin, group), "should not admin group"
    assert user.may?(:edit, committee)
    assert user.may?(:edit, group)
    #assert !user.may?(:admin, committee), "should not admin committee of group with council."
    # ^^ i am not sure if group members should stripped of admin rights for
    # committees if there is a council. I think that it is OK if they
    # keep their admin rights to committees.

    # add a user to the council
    council.add_user! user
    assert user.may?(:admin, group), 'should now have admin access again'
    assert user.may?(:admin, committee), 'should now have admin access again'

    # destroy the council
    council.remove_user!(user)
    assert !user.may?(:admin, group), 'should be booted from council'
    council.destroy_by(user)
    user.clear_access_cache
    assert user.may?(:admin, group), 'should be able to admin group again'
  end

  def test_search
    user = users(:red)

    # test search
    correct_visible_groups = Group.find(:all, :conditions => 'type IS NULL').select do |g|
      user.may?(:view,g)
    end
    visible_groups = Group.with_access(user => :view).only_groups.find(:all)
    correct_names = correct_visible_groups.collect{|g|g.name}.sort
    names         = visible_groups.collect{|g|g.name}.sort

    assert names.length > 0
    assert_equal correct_names, names
  end

  def test_group_visibility
    user = FactoryGirl.create(:user, :login => 'earth')

    # create an invisible group
    invisible = FactoryGirl.create(:group)
    invisible.revoke_access!(:public => :view)
    assert !user.may?(:view, invisible), "should not view group i'm not in."

    # add back ability so see
    invisible.grant_access!(:public => [:view, :pester])
    assert user.may?(:pester, invisible)
  end

  def test_find_committee
    user = users(:red)

    correct_visible_groups = Committee.find(:all).select do |g|
      user.may?(:view,g)
    end
    visible_groups = Committee.with_access(user => :view).find(:all)

    correct_names = correct_visible_groups.collect{|g|g.name}.sort
    names         = visible_groups.collect{|g|g.name}.sort

    assert_equal  correct_names, names
  end
end
