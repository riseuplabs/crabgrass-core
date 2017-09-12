module WikiTestHelper
  def assert_latest_body(wiki, body)
    assert_equal body, wiki.body, 'should have the latest body'
    assert_equal body, wiki.versions.last.body, 'should have the latest body for its most recent version'
  end

  def assert_latest_body_html(wiki, body_html)
    assert_equal body_html, wiki.body_html, 'should have the latest body_html'
    assert_equal body_html, wiki.versions.last.body_html, 'should have the latest body_html for its most recent version'
  end

  def assert_latest_raw_structure(wiki, raw_structure)
    assert_equal raw_structure, wiki.raw_structure, 'should have the latest raw_structure'
    assert_equal raw_structure, wiki.versions.last.raw_structure, 'should have the latest raw_structure for its most recent version'
  end
end
