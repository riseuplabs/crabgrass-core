require 'javascript_integration_test'

class PeopleDirectoryTest < JavascriptIntegrationTest

  def setup
    super
    @user = users(:blue)
    login
  end

  def test_search
    click_on 'People'
    click_on 'Search'
    autocomplete 'user_name', with: 'red'
    assert_content 'Red'
  end


end
