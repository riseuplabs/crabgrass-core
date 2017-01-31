require 'test_helper'

class Notice::PrivateMessageNoticeTest < ActiveSupport::TestCase


  def test_post_deletion_dismiss_its_notice
    blue, orange = users(:blue), users(:orange)
    relationship = blue.add_contact! orange
    relationship.send_message 'Hi, Orange! 1'
    message_to_destroy = relationship.send_message 'Hi, Orange! 2'
    assert_equal 2, Notice::PrivateMessageNotice.where(dismissed: false).count

    private_notice_for_deleted_post = Notice::PrivateMessageNotice.last
    message_to_destroy.destroy
    assert_equal 1, Notice::PrivateMessageNotice.where(dismissed: false).count

    assert_raises ActiveRecord::RecordNotFound,
      "Notice is deleted when post is deleted" do
      private_notice_for_deleted_post.reload
    end
  end
end

