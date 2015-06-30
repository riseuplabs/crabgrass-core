require_relative 'test_helper'

class PrivateMessageNoticeTest < ActiveSupport::TestCase
  fixtures :users

  def test_post_deletion_dismiss_its_notice
    blue, orange = users(:blue), users(:orange)
    relationship = blue.add_contact! orange
    relationship.send_message 'Hi, Orange! 1'
    message_to_destroy = relationship.send_message 'Hi, Orange! 2'
    assert_equal 2, PrivateMessageNotice.where(dismissed: false).count

    message_to_destroy.destroy
    assert_equal 1, PrivateMessageNotice.where(dismissed: false).count

    private_notice_for_deleted_post = PrivateMessageNotice.last
    assert private_notice_for_deleted_post.dismissed?
    message_hash = { message: "<p>Hi, Orange! 2</p>", from: blue.name }
    assert_equal message_hash, private_notice_for_deleted_post.data
  end
end

