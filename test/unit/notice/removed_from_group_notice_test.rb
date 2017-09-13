require 'test_helper'

class RemovedFromGroupNoticeTest < ActiveSupport::TestCase

  def setup
    @blue, @orange = users(:blue), users(:orange)
    @rainbow = groups(:rainbow)
  end

# TODO: write controller test instead

  def test_remove_from_group
#    assert @orange.member_of? @rainbow
#    @rainbow.remove_user! @orange
    Notice::UserRemovedNotice.create! group: @rainbow, user: @orange
    notice = Notice::UserRemovedNotice.last(1)
    assert_equal 'membership_notification', notice.first.data[:title]
#    assert_not @orange.member_of? @rainbow
  end

end
