require 'test_helper'
#
# Request Model Test
#
# Request is an abstract class. We only use subclasses of it.
# This test aims at testing the abstract class - in particular
# to make sure permissions are checked.
#
class RequestModelTest < ActiveSupport::TestCase
  def test_create_checks_permission
    request = Request.new created_by: User.new
    assert !request.save
    assert_includes request.errors[:base],
      'Permission Denied'
  end

  def test_mark_as_destroy_checks_permission
    request = Request.new created_by: User.new
    assert_raises PermissionDenied do
      request.mark! :destroy, User.new
    end
  end

  def test_mark_as_approved_checks_permission
    user = FactoryBot.create :user
    request = RequestICanCreate.create created_by: user,
      recipient: user,
      requestable: user
    assert_raises PermissionDenied do
      request.mark! :approve, User.new
    end
  end

  def test_mark_as_rejected_checks_permission
    user = FactoryBot.create :user
    request = RequestICanCreate.create created_by: user,
      recipient: user,
      requestable: user
    assert_raises PermissionDenied do
      request.mark! :reject, User.new
    end
  end

  #
  # The Request base class does not allow creating requests.
  #
  # Subclassed need to overwrite the permissions.  For some tests we
  # need a persisted request - mostly because of checks against
  # :new_record? in request.mark!.  That's what we use this class for.
  #
  class RequestICanCreate < Request
    protected
    def may_create?(_user)
      true
    end
  end
end
