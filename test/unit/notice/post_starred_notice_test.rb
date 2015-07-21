require 'test_helper'

class PostStarredNoticeTest < ActiveSupport::TestCase

  def test_render_without_post
    notice = PostStarredNotice.new
    assert notice.display_title.present?
    assert_equal "", notice.display_body
  end


end
