require 'test_helper'

class Group::CommitteeTest < ActiveSupport::TestCase


  def setup
    #@group = groups[:rainbow]
    #@c1 = groups[:warm]
    #@c2 = groups[:cold]
  end

  def test_creation_and_deletion
    g = Group.create name: 'riseup'
    c1 = Group::Committee.create name: 'finance'
    c2 = Group::Committee.create name: 'food'

    assert_difference 'Group.find(%d).version'%g.id do
      g.add_committee!(c1)
    end
    assert_difference 'Group.find(%d).version'%g.id do
      g.add_committee!(c2)
    end
    g.reload
    assert_equal g, c1.parent, "committee's parent should match group"

    assert_difference 'Group.find(%d).version'%g.id do
      assert_difference 'Group.find(%d).committees.count'%g.id, -1 do
        c1.destroy
      end
    end
    g.destroy
    assert_nil Group::Committee.find_by_name('food'), 'committee should die with group'
  end

  def test_destroy_group
    assert_nothing_raised do
      Group.find(groups(:warm).id)
    end
    groups(:rainbow).destroy
    assert_raises ActiveRecord::RecordNotFound, 'committee should be destroyed' do
      Group.find(groups(:warm).id)
    end
  end

  def test_membership
    g = Group.create name: 'riseup'
    c1 = Group::Committee.create name: 'finance'
    c2 = Group::Committee.create name: 'food'
    g.add_committee!(c1)
    g.add_committee!(c2)
    user = users(:kangaroo)

    assert(!user.member_of?(g), 'user should not be member yet')

    g.add_user!(user)

    assert user.member_of?(g), 'user should be member of group'
    assert user.member_of?(c1), 'user should also be a member of committee'
    assert(user.direct_member_of?(g), 'user should be a direct member of the group')
    assert(!user.direct_member_of?(c1), 'user should not be a direct member of the committee')
    g.remove_user!(user)

    assert(!user.member_of?(g), 'user should not be member of group after being removed')
    assert(!user.member_of?(c1), 'user should not be a member of committee')
  end

  def test_naming
    g = Group.create name: 'riseup'
    c = Group::Committee.new name: 'outreach'
    g.add_committee!(c)
    assert_equal 'riseup+outreach', c.name,
      'committee name should be in the form <groupname>+<committeename>'
    c.name = 'legal'
    c.save
    assert_equal 'riseup+legal', c.name,
      'committee name update when changed.'
    g.reload
    g.name = 'riseup-collective'
    g.save
    assert_equal 'riseup-collective+legal', g.committees.first.name,
      'committee name update when group name changed.'
  end

  def test_create
    g = Group::Committee.create
    assert !g.valid?, 'committee with no name should not be valid'
  end

  def test_associations
    # current_user_permissions needs a current user
    assert check_associations(Group::Committee)
  end

  def test_member_of_committee_but_not_of_group_cannot_access_group_pages
    g = Group.create name: 'riseup'
    c = Group::Committee.create name: 'outreach'
    g.add_committee!(c)
    user = users(:gerrard)
    other_user = users(:blue)
    c.add_user!(user)
    c.add_user!(other_user)
    g.add_user!(other_user)

    group_page = Page.create! title: 'a group page',
      public: false,
      user: other_user,
      share_with: g, access: :admin
    group_page.save
    committee_page = Page.create! title: 'a committee page',
      public: false,
      user: other_user,
      share_with: c, access: :admin
    committee_page.save

    assert user.may?(:view, committee_page), "should be able to view committee page"
    assert !user.may?(:view, group_page), "should not be able to view group page"
  end

  def test_cant_pester_private_committee
    g = Group.create name: 'riseup'
    c = Group::Committee.create name: 'outreach'
    g.add_committee!(c)

    u = User.create login: 'user'

    assert u.may?(:pester, c) == false, 'should not be able to pester committee of group with private committees'
  end

  def test_can_pester_public_committee
    g = Group.create name: 'riseup'
    g.grant_access! public: [:view, :pester, :see_committees]
    c = Group::Committee.create name: 'outreach'
    c.grant_access! public: [:view, :pester]
    g.add_committee!(c)

    u = User.create login: 'user'

    assert u.may?(:pester, c), 'should be able to pester committee of group with public committees'
  end
end
