require File.dirname(__FILE__) + '/test_helper'

class CommitteeTest < ActiveSupport::TestCase
  fixtures :groups, :users

  def test_add_council
    network = groups(:cnt)
    council = Council.create!(:name => 'council')
    network.add_committee!(council)
    network.reload
    council.reload
    assert_equal 'Network', network.type
    assert_equal 'Council', council.type
    assert_equal council.id, network.council_id
    assert_equal council, network.council
    assert_equal network.id, council.parent_id
  end

  def test_add_council_with_full_powers
    g = Group.create :name => 'boosh'
    # only one user added
    g.add_user!(users(:blue))

    council = Council.create!(:name => 'council')
    g.add_committee!(council)

    council.reload
    assert council.full_council_powers?
  end

  def test_add_council_without_full_powers
    g = Group.create :name => 'boosh'
    # two users added
    g.add_user!(users(:blue))
    g.add_user!(users(:yellow))

    council = Council.create!(:name => 'council')
    g.add_committee!(council)

    council.reload
    assert !council.full_council_powers?
  end

  def test_council_takes_admin_from_group_members
    g = Group.create :name => 'boosh'
    g.add_user!(users(:yellow))
    g.add_user!(users(:blue))

    council = Council.create!(:name => 'council')
    g.add_committee!(council)

    council.add_user!(users(:blue))

    assert !users(:yellow).may?(:admin, g)
    assert users(:blue).may?(:admin, g)
  end

  def test_removing_council_brings_admin_back_to_group
    g = Group.create :name => 'boosh'
    g.add_user!(users(:yellow))
    g.add_user!(users(:blue))

    council = Council.create!(:name => 'council')
    g.add_committee!(council)

    council.add_user!(users(:blue))
    g.destroy_council

    g.reload
    assert_equal g, g.council
    assert users(:yellow).may?(:admin, g)
  end

  def test_remove_council_from_network
    network = groups(:cnt)
    council = Council.create!(:name => 'council')
    network.add_committee!(council)
    network.destroy_council

    network.reload
    assert_equal network, network.council

  end
end


