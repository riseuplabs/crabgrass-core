require 'test_helper'

class Notice::PostStarredNoticeTest < ActiveSupport::TestCase

  def test_render_without_post
    notice = Notice::PostStarredNotice.new
    assert notice.display_title.present?
    assert_equal "", notice.display_body
  end


end
