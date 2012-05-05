require 'test_helper'

class NoticeTest < ActiveSupport::TestCase
  fixtures :users

  test "request observers" do
    req = nil
    assert_difference 'RequestNotice.count' do
      req = RequestToFriend.create! :recipient => users(:yellow), :created_by => users(:green)
    end
    assert_equal req, Notice.first.request
    assert_difference 'RequestNotice.count', -1 do
      req.set_state!('approved', users(:yellow))
    end
  end

end
