require File.dirname(__FILE__) + '/../../../test_helper'
require File.dirname(__FILE__) + '/../test_case'

class Groups::BasePermissionTest < Permission::TestCase

  def test_may_destroy_group
    login_as User.make
    group = Group.make
    assert @controller.send :may_destroy_group?, group
  end

end
