require 'test_helper'

class Page::CommentsTest < ActiveSupport::TestCase


  def setup
    @user = users(:blue)
    @page = @user.pages.last
  end

  def test_posting_comment
    text = Faker::Lorem.paragraph
    @page.add_post(@user, body: text)
    assert @page.discussion.present?
    assert_equal 1, @page.discussion.posts_count
    assert @page.page_terms.comments.include? text
  end


end
