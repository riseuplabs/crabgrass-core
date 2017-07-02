require 'javascript_integration_test'

class DiscussionIntegrationTest < JavascriptIntegrationTest
  include Integration::Comments

  def setup
    super
    own_page
    login
    click_on own_page.title
  end

  def test_posting
    comment = post_comment "It is a discussion. So let us comment some."
    assert_content comment
  end

  def test_editing_own_comment
    comment = post_comment "It is a discussion. So let us comment some."
    new = edit_comment comment, "It is a discussion. So what?"
    assert_content new
    assert_no_content comment
  end

  def test_format_help
    find('.new_post').click_on 'Editing Help'
    help = windows.last
    within_window help do
      assert_content 'GreenCloth'
    end
  end

end
