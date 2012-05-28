require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../app/controllers/common/application/guard.rb')
class Common::Application::PermissionsTest < ActiveSupport::TestCase

  class GuardStubController < Common::Application::StubController
    include Common::Application::Guard
  end

  class InheritedStubController < GuardStubController
  end

  # reset the original
  def teardown
    cleanup(GuardStubController)
  end

  def test_default_function_name
    GuardStubController.guard :may_do_this?
    assert_equal :may_do_this?, GuardStubController.permission_for_action(:dance)
  end

  def test_undefined_permission_raises
    GuardStubController.guard :may_do_this?, :actions => [:juggle, :default]
    assert_equal false, GuardStubController.permission_for_action(:dance)
  end

  def test_actions_can_be_single_symbol
    GuardStubController.guard :may_do_this?, :actions => :dance
    assert_equal :may_do_this?, GuardStubController.permission_for_action(:dance)
  end

  def test_default_does_not_override
    GuardStubController.guard :may_do_this?, :actions => [:dance, :juggle]
    GuardStubController.guard :may_do_that?
    assert_equal :may_do_this?, GuardStubController.permission_for_action(:dance)
  end

  def test_later_actions_overwrite
    GuardStubController.guard :may_do_that?, :actions => [:dance, :juggle]
    GuardStubController.guard :may_do_this?, :actions => [:dance, :default]
    assert_equal :may_do_this?, GuardStubController.permission_for_action(:dance)
  end

  def test_action_wildcard
    GuardStubController.guard :may_ACTION_this?, :actions => [:dance, :juggle]
    assert_equal :may_dance_this?, GuardStubController.permission_for_action(:dance)
  end

  def test_action_alias_wildcard
    GuardStubController.guard :may_ALIAS_this?
    assert_equal :may_edit_this?, GuardStubController.permission_for_action(:update)
    assert_equal :may_create_this?, GuardStubController.permission_for_action(:new)
    assert_equal :may_dance_this?, GuardStubController.permission_for_action(:dance)
  end

  def test_cache_wildcard_replacement
    GuardStubController.guard :may_ALIAS_this?
    assert_equal :may_edit_this?, GuardStubController.permission_for_action(:update)
    class << GuardStubController
      alias :normal_replace_wildcards :replace_wildcards
      undef replace_wildcards
    end
    assert_equal :may_edit_this?, GuardStubController.permission_for_action(:update)
    class << GuardStubController
      alias :replace_wildcards :normal_replace_wildcards
      undef normal_replace_wildcards
    end
  end

  def test_inheriting_actions
    GuardStubController.guard :may_ALIAS_this?, :actions => [:edit, :update]
    assert_equal :may_edit_this?, InheritedStubController.permission_for_action(:update)
    cleanup(InheritedStubController)
  end

  def test_inheriting_default
    GuardStubController.guard :may_ALIAS_this?
    assert_equal :may_edit_this?, InheritedStubController.permission_for_action(:update)
    cleanup(InheritedStubController)
  end

  def test_caching_does_not_mess_with_inheritance
    GuardStubController.guard :may_ALIAS_this?, :actions => [:edit, :update]
    InheritedStubController.guard :may_update_that?, :actions => :update
    assert_equal :may_edit_this?, GuardStubController.permission_for_action(:update)
    assert_equal :may_update_that?, InheritedStubController.permission_for_action(:update)
    cleanup(InheritedStubController)
  end

  # HELPERS

  def cleanup(klass)
    klass.class_eval do
      @permission_cache = nil
      @action_map = nil
    end
  end
end
