require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../../../../app/controllers/common/application/permissions.rb')
class Common::Application::PermissionsTest < ActiveSupport::TestCase

  class PermissionStubController < Common::Application::StubController
    include Common::Application::Permissions

    def may_create_stub?
      true
    end

    def may_create_group_stub?
      true
    end

    def may_list_group_stubs?
      true
    end
  end

  def setup
    @controller = PermissionStubController.new
  end

  def teardown
    # clear the permission options:
    @controller.class.send :permissions, {}
  end

  def test_default_function_name
    @controller.params.merge! :action => 'create'
    assert_equal "may_create_stub?", @controller.send(:find_permission_method)
  end

  def test_alias_function_name
    @controller.params.merge! :action => 'new'
    assert_equal "may_create_stub?", @controller.send(:find_permission_method)
  end

  def test_no_function_name_with_object_prefix
    @controller.params.merge! :action => 'create', :controller => 'stub/settings'
    assert_nil @controller.send(:find_permission_method)
  end

  def test_no_function_name_with_object_postfix
    @controller.params.merge! :action => 'create', :controller => 'me/stub'
    assert_nil @controller.send(:find_permission_method)
  end

  def test_function_name_with_altered_object
    @controller.params.merge! :action => 'create', :controller => 'other'
    @controller.class.send :permissions, :object => 'stub'
    assert_equal "may_create_stub?", @controller.send(:find_permission_method)
  end

  def test_function_name_with_altered_object_does_not_fall_back
    @controller.params.merge! :action => 'create'
    @controller.class.send :permissions, :object => 'other'
    assert_nil @controller.send(:find_permission_method)
  end

  def test_function_name_with_altered_verb
    @controller.params.merge! :action => 'other'
    @controller.class.send :permissions, :verb => 'create'
    assert_equal "may_create_stub?", @controller.send(:find_permission_method)
  end

  def test_function_name_with_altered_verb_does_not_fall_back
    @controller.params.merge! :action => 'create'
    @controller.class.send :permissions, :verb => 'other'
    assert_nil @controller.send(:find_permission_method)
  end

  def test_function_name_with_proper_singularization
    @controller.params.merge! :action => 'create', :controller => 'groups/stubs'
    assert_equal "may_create_group_stub?", @controller.send(:find_permission_method)
  end

  def test_function_name_with_proper_pluralization
    @controller.params.merge! :action => 'list', :controller => 'groups/stub'
    assert_equal "may_list_group_stubs?", @controller.send(:find_permission_method)
  end



end
