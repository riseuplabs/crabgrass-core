# encoding: utf-8

require 'javascript_integration_test'

class PageSearchTest < JavascriptIntegrationTest
  include Integration::Search

  def test_sphinx
    user = users(:blue)
    page = user.pages.first
    pages = Page.find_by_path "text/#{page.title}", method: :mysql
    assert pages.count >= 1
    pages = Page.find_by_path "text/#{page.title}", method: :sphinx
    assert pages.count >= 1
  end

  def test_initial_search
    user = users(:blue)
    page = user.pages.last
    login user
    click_on 'Pages'
    assert_content page.title
  end

  def test_owned_by_me
    user = users(:blue)
    page = user.pages_owned.first
    login user
    click_on 'Pages'
    click_on 'Own'
    assert_content 'Owned By Me'
    assert_text_of_all 'td.owner', user.display_name
    assert_content page.title
  end

  def test_deleted
    user = users(:blue)
    page = pages(:delete_test)
    login user
    click_on 'Pages'
    assert_content 'Owner'
    assert_no_content page.title
    click_on 'Deleted'
    assert_content page.title
  end

  def test_tagged
    user = users(:blue)
    tag = tags(:special_chars).name
    page = user.pages.tagged_with(tag).first
    login user
    click_on 'Pages'
    click_on 'Tag...'
    click_on tag
    assert_content "Tag: #{tag}"
    assert_content page.title
  end

  def assert_text_of_all(selector, text)
    all(selector).each do |elem|
      assert_equal text, elem.text
    end
  end
end
