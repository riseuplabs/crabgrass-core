require 'javascript_integration_test'

class PageSideBarTest < JavascriptIntegrationTest

  def setup
    super
    own_page
    login
    click_on own_page.title
  end

  def test_trash
    click_on 'Delete Page'
    click_button 'Delete'
    # finish deleting...
    assert_content 'Notices'
    assert_no_content own_page.title
    assert_equal FLOW[:deleted], own_page.reload.flow
  end

  def test_destroy
    click_on 'Delete Page'
    choose 'Destroy Immediately'
    click_button 'Delete'
    # finish deleting...
    assert_content 'Notices'
    assert_no_content own_page.title
    assert_nil Page.where(id: own_page.id).first
  end

  def test_tag
    tags = %w/some tags for this page/
    tag_page tags
    assert_page_tags tags
  end

end
