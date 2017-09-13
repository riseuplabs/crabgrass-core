require 'test_helper'
require 'page/finder'

class Page::FinderTest < ActiveSupport::TestCase
  def test_finds_page
    page = pages(:blue_page)
    finder = find 'blue', 'blue_page'
    assert_equal page, finder.page
    assert_equal users(:blue), finder.user
  end

  def test_finds_page_in_different_context
    page = pages(:blue_page)
    finder = find 'rainbow', 'blue_page'
    assert_equal page, finder.page
    assert_equal groups(:rainbow), finder.group
  end

  def test_missing_page
    finder = find 'blue', 'blasdfsadfsdfpage'
    assert_nil finder.page
    assert_equal users(:blue), finder.user
  end

  def test_missing_context
    finder = find 'blsadfaerue', 'blasdfsadfsdfpage'
    assert_nil finder.page
  end

  def test_find_page_by_id
    page = pages(:blue_page)
    finder = find 'blsadfaerue', 'blasdfsadfsdfpage+1002'
    assert_equal page, finder.page
  end

  def test_returns_nil_on_multiple_pages
    finder = find 'rainbow', 'page'
    assert_nil finder.page
  end

  protected

  def find(context, handle)
    Page::Finder.new(context, handle)
  end
end
