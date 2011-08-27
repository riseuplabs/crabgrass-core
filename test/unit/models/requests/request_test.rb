require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class RequestTest < ActiveSupport::TestCase

  def test_create_checks_permissions
    user = User.make
    request = Request.new :created_by => user
    request.expects(:may_create?).with(user).returns(false)
    assert !request.save
  end

  def test_mark_as_destroy_checks_permission
    user = User.make
    request = Request.new :created_by => user
    request.save_with_validation(false)
    assert_raises PermissionDenied do
      request.expects(:may_destroy?).with(user).returns(false)
      request.mark! :destroy, user
    end
  end

  def test_mark_as_approved_checks_permission
    user = User.make
    request = Request.new :created_by => user
    request.save_with_validation(false)
    assert_raises PermissionDenied do
      request.expects(:may_approve?).with(user).returns(false)
      request.mark! :approve, user
    end
  end

  def test_mark_as_rejected_checks_permission
    user = User.make
    request = Request.new :created_by => user
    request.save_with_validation(false)
    assert_raises PermissionDenied do
      request.expects(:may_approve?).with(user).returns(false)
      request.mark! :reject, user
    end
  end
end
