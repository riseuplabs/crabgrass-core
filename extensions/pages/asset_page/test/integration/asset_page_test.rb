require 'javascript_integration_test'

class AssetTypeChangeTest < JavascriptIntegrationTest
  include Integration::Navigation

  def setup
    super
    login
    create_page :asset_page
  end

  def test_replacing_with_different_file_type
    assert_page_header
    assert_content 'bee'
    update_asset 'test.pdf'
    assert_content 'Portable Document Format'
    click_page_tab 'History'
    assert_content 'version 2'
    remove_version
    assert_no_content 'version 1'
  end

  def test_showing_version
    assert_page_header
    assert_content 'bee'
    update_asset 'test.pdf'
    assert_content 'Portable Document Format'
    click_page_tab 'History'
    click_on 'version 2'
    assert_download "application/pdf", "test.pdf"
  end

  protected

  def update_asset(filename)
    click_page_tab 'Edit'
    attach_file :asset_uploaded_data, fixture_file(filename)
    click_on 'Upload'
  end

  def remove_version
    click_on 'Remove'
    click_on 'OK'
  end

  def assert_download(content_type, filename)
    assert_includes page.response_headers.keys, 'Content-Disposition',
      'Looks like nothing was downloaded'
    assert_includes page.response_headers['Content-Type'], content_type
    assert_includes page.response_headers['Content-Disposition'],
      "filename=\"#{filename}\""
  end
end
