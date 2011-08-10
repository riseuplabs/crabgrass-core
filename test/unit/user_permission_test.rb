require File.dirname(__FILE__) + '/../test_helper'

class UserPermissionTest < ActiveSupport::TestCase

  def setup
    @me = User.make
  end

  def test_defaults
    assert @me.has_access? :view, :public
    assert @me.has_access? :pester, :public
    assert !@me.has_access?(:see_groups, @me.friends)
  end

  def test_dependencies
    @me.revoke! @me.friends, :view
    assert !@me.has_access?(:view, :public)
    assert @me.has_access? :view, @me.peers
    @me.grant! :public, :view
    assert @me.has_access? :view, @me.friends
    assert @me.has_access? :view, @me.peers
  end
end
