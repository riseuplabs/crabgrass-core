require 'javascript_integration_test'

class AssetPageTest < JavascriptIntegrationTest
  include Integration::Navigation

  def setup
    super
    login
    create_page :asset_page
  end

  def test_replacing_with_different_file_type
    assert_page_header
    assert_content "bee"
    update_asset 'test.pdf'
    assert_content 'Portable Document Format'
    click_page_tab 'History'
    assert_content 'version 2'
    remove_version
    assert_no_content 'version 1'
  end

  def update_asset(filename)
    click_page_tab 'Edit'
    attach_file :asset_uploaded_data, fixture_file(filename)
    click_on 'Upload'
  end

  def remove_version
    click_on 'Remove'
    click_on 'OK'
  end
end
