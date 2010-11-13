require File.dirname(__FILE__) + '/../test_helper'

class PermissionsTest < ActiveSupport::TestCase

  fixtures :users, :groups, :profiles, :permissions

  def test_find_group
    user = users(:red)

    correct_visible_groups = Group.find(:all, :conditions => 'type IS NULL').select do |g|
      user.may?(:view,g)
    end
    visible_groups = Group.with_access(:see, user).only_groups.find(:all)

    correct_names = correct_visible_groups.collect{|g|g.name}.sort
    names         = visible_groups.collect{|g|g.name}.sort

    assert_equal  correct_names, names
  end

  def test_find_committee
    user = users(:red)

    correct_visible_groups = Committee.find(:all).select do |g|
      user.may?(:view,g)
    end
    visible_groups = Committee.visible_by(user).find(:all)

    correct_names = correct_visible_groups.collect{|g|g.name}.sort
    names         = visible_groups.collect{|g|g.name}.sort

    assert_equal  correct_names, names
  end
end
