require 'test_helper'

class RemovedFromGroupNoticeTest < ActiveSupport::TestCase

  def setup
    @user = FactoryGirl.create :user
    @group = FactoryGirl.create :group
  end

  def test_remove_from_group
    Notice::UserRemovedNotice.create! group: @group, user: @user
    notice = Notice::UserRemovedNotice.last(1)
    assert_equal 'membership_notification', notice.first.data[:title]
  end

end
