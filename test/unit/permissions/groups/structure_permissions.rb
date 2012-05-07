require 'rubygems'
require 'minitest/autorun'
require 'mocha'
require File.dirname(__FILE__) + '/../test_helper'

module Groups
  require RAILS_ROOT + '/app/permissions/groups/structures_permission'

  class StructuresPermissionTest < MiniTest::Unit::TestCase
    include StructuresPermission

    attr_accessor :current_user

    def test_may_not_create_council_for_old_multi_user_group
      @group = stub_group
      self.current_user = stub_admin
      assert !may_create_council?
    end

    def test_may_create_council_for_single_user_group
      @group = stub_group(:single_user? => true)
      self.current_user = stub_admin
      assert may_create_council?
    end

    def test_may_create_council_for_recent_group
      @group = stub_group(:recent? => true)
      self.current_user = stub_admin
      assert may_create_council?
    end

    def test_may_not_create_duplicate_council
      @group = stub_group(:has_a_council? => true)
      self.current_user = stub_admin
      assert !may_create_council?
    end

    def test_may_not_create_council_for_class_without_councils
      @group = stub_group(:class => stub(:can_have_council? => false))
      self.current_user = stub_admin
      assert !may_create_council?
    end

    def test_may_not_create_council_if_no_admin
      @group = stub_group(:recent? => true)
      self.current_user = stub_admin(@group, false)
      assert !may_create_council?
    end

    def stub_group(options = {})
      defaults = {
        :class => stub(:can_have_council? => true),
        :has_a_council? => false,
        :recent? => false,
        :single_user? => false
      }
      stub(defaults.merge(options))
    end

    def stub_admin(group = @group, ret = true)
      user = Object.new
      user.expects(:may?).with(:admin, group).returns(ret).at_most_once
      user
    end

  end
end
