require 'test_helper'

class User::PermissionTest < ActiveSupport::TestCase

  def setup
    @me = FactoryGirl.create(:user)
    @other = FactoryGirl.create(:user)
  end

  def test_defaults
    assert @me.access?(@me.associated(:friends) => :view)
    assert @me.access?(@other => :request_contact)
    assert !@me.access?(public: :see_groups)
    assert !@me.access?(@me.associated(:peers) => :see_groups)
    assert @me.access?(@me.associated(:friends) => :see_groups)
  end

  #
  # defaults no longer handled this way
  #
  # def test_setting_defaults
  #   original_permissions = Conf.default_user_permissions
  #   Conf.default_user_permissions['peers'] = ['see_contacts']
  #   @you = User.make
  #   assert @you.has_access? :see_contacts, @you.peers
  #   assert !@me.has_access?(:see_contacts, @me.peers)
  #   assert !@you.has_access?(:request_contact, @you.peers)
  #   assert @me.has_access?(:request_contact, @me.peers)
  #   Conf.default_user_permissions = original_permissions
  # end

  def test_dependencies
    friends = @me.associated(:friends)
    peers   = @me.associated(:peers)
    @me.revoke_access!(friends => :view)
    assert !@me.access?(friends => :view)
    @me.grant_access!(public: :view)
    assert @me.access?(friends => :view)
    assert @me.access?(peers => :view)
    @me.revoke_access!(friends => :view)
    assert !@me.access?(public: :view)
    assert @me.access?(peers => :view)
  end

  def test_finders
    accessible = User.with_access(@me => :pester)
    assert accessible.where(id: @other).exists?
  end
end
