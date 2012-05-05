#
# Also see page_sharing_test.rb for PageNotice related tests
#

require File::dirname(__FILE__) + '/../test_helper'

class NoticeTest < ActiveSupport::TestCase
  fixtures :users

  test "request observers" do
    req = nil
    assert_difference 'RequestNotice.count' do
      req = RequestToFriend.create! :recipient => users(:yellow), :created_by => users(:green)
    end
    assert_equal req, RequestNotice.for_noticable(req).find(:first).request
    assert_difference 'RequestNotice.dismissed(true).count' do
      req.set_state!('approved', users(:yellow))
    end
  end

end
