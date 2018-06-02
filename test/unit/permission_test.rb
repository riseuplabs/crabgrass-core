require 'test_helper'

class PermissionTest < ActiveSupport::TestCase

  def test_group_permissions_with_committee_and_council
    # create a group and user
    user = FactoryBot.create(:user, login: 'earth')
    group = FactoryBot.create(:group, name: 'planets')
    group.add_user! user
    assert user.may?(:admin, group), "should admin group i'm in"

    # add a committee
    committee = FactoryBot.create(:committee)
    group.add_committee! committee

    assert user.may?(:admin, committee), 'should admin committee of my group.'

    # add a council
    committee_for_council = FactoryBot.create(:committee, name: 'astrophysicists')
    group.add_council!(committee_for_council)
    council = Group.find(committee_for_council.id)
    assert !user.may?(:admin, group), 'should not admin group'
    assert user.may?(:edit, committee)
    assert user.may?(:edit, group)
    # assert !user.may?(:admin, committee), "should not admin committee of group with council."
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
    council.destroy
    assert user.may?(:admin, group), 'should be able to admin group again'
  end

  def test_search
    user = users(:red)

    # test search
    correct_visible_groups = Group.where('type IS NULL').select do |g|
      user.may?(:view, g)
    end
    visible_groups = Group.with_access(user => :view).only_groups
    correct_names = correct_visible_groups.collect(&:name).sort
    names         = visible_groups.pluck(:name).sort

    assert !names.empty?
    assert_equal correct_names, names
  end

  def test_group_visibility
    user = FactoryBot.create(:user, login: 'earth')

    # create an invisible group
    invisible = FactoryBot.create(:group)
    invisible.revoke_access!(public: :view)
    assert !user.may?(:view, invisible), "should not view group i'm not in."

    # add back ability so see
    invisible.grant_access!(public: %i[view pester])
    assert user.may?(:pester, invisible)
  end

  def test_find_committee
    user = users(:red)

    correct_visible_groups = Group::Committee.all.select do |g|
      user.may?(:view, g)
    end
    visible_groups = Group::Committee.with_access(user => :view)

    correct_names = correct_visible_groups.collect(&:name).sort
    names         = visible_groups.pluck(:name).sort

    assert_equal  correct_names, names
  end
end
