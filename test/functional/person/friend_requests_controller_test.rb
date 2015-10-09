require_relative '../../test_helper'

class Person::FriendRequestsControllerTest < ActionController::TestCase

  fixtures :users

  def test_new_contact_request_notifies_recipient
    requesting = users(:blue)
    recipient  = users(:yellow)
    login_as requesting

    # Stub permission access for current test case
    def requesting.may?(*args)
      true
    end

    assert_difference 'RequestNotice.count', 1 do
      xhr :post, :create, person_id: recipient.login
    end

    notice = RequestNotice.last
    assert_equal recipient.id, notice.user_id
    assert_equal 'request_to_friend', notice.data[:title]
  end

end
