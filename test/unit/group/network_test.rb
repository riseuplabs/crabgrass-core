require 'test_helper'

class Group::NetworkTest < ActiveSupport::TestCase
  def test_creation
    network = Group::Network.create! name: 'robot-federation', initial_member_group: groups(:rainbow)
    assert Group.find_by_name('rainbow').member_of?(network)
  end

  def test_creation_without_initial_member_group_doesnt_work
    network = Group::Network.create name: 'robot-federation'

    assert !network.valid?
    assert_equal ["can't be blank"], network.errors['initial_member_group']
  end

  def test_member_of
    user = users(:blue)
    group = groups(:animals)
    network = groups(:fau)
    assert !user.direct_member_of?(network)
    assert user.member_of?(group)
    assert network.groups.include?(group)
    assert user.member_of?(network)
    assert user.all_group_ids.include?(network.id)
  end

  def test_add_whole_groups
    network = groups(:fai)
    group1 = groups(:animals)
    group2 = groups(:rainbow)

    version = network.version

    assert_nothing_raised do
      network.add_group!(group1)
      network.add_group!(group2)
    end

    assert network.groups.include?(group1)
    assert network.groups.include?(group2)

    assert network.groups.reload.include?(group1)
    assert network.groups.reload.include?(group2)

    assert_equal version + 2, network.reload.version

    user = users(:red)

    assert !user.direct_member_of?(network)
    assert user.member_of?(network), "user should be a member of the network (all group ids = #{user.all_group_id_cache.inspect})"

    user2 = users(:kangaroo)
    assert user2.member_of?(network)
    assert !user.peer_of?(user2)
  end

  def test_network_council
    network = groups(:fai)
    group   = groups(:rainbow)
    delegation = groups(:warm)

    network.add_committee!(Group::Committee.create(name: 'spokescouncil'), true)
    network.add_group!(group, delegation)
  end

  def test_leave_network
    network = groups(:fau)
    group   = groups(:animals)
    user    = users(:blue)
    assert user.direct_member_of?(group)
    assert user.member_of?(network)

    assert_nothing_raised do
      network.remove_group!(group)
    end

    assert !network.groups.include?(group)
    assert !network.groups.reload.include?(group)

    user = User.find(user.id)
    assert !user.member_of?(network), "user should NOT be a member of the network (all group ids = #{user.all_group_id_cache.inspect})"
  end

  # what happens when a network is a member of a network?
  def test_nested_network
    parent_network = groups(:fai)
    child_network  = groups(:cnt)
    user = users(:gerrard)
    group = groups(:true_levellers)

    committee = Group::Committee.create! name: 'fai+committee'
    parent_network.add_committee!(committee)

    assert user.member_of?(group)
    assert child_network.groups.include?(group)
    assert user.member_of?(child_network)
    assert !user.direct_member_of?(child_network)
    assert committee.parent == parent_network

    assert_raises ActiveRecord::RecordInvalid do
      parent_network.add_group!(child_network)
    end

    assert user.reload.member_of?(parent_network)
    assert user.member_of?(committee)
  end

  def test_associations
    assert check_associations(Group::Network)
    assert check_associations(Group::Federating)
  end
end
