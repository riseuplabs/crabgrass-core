require 'javascript_integration_test'

class PeopleDirectoryTest < JavascriptIntegrationTest

  def setup
    super
    @user = users(:blue)
    login
  end

  def test_contacts
    click_on 'People'
    assert_no_autocomplete 'user_name', with: 'red'
    autocomplete 'user_name', with: 'orange'
    assert_content 'Orange'
  end

  def test_peers
    click_on 'People'
    click_on 'Peers'
    assert_no_autocomplete 'user_name', with: 'aaron'
    autocomplete 'user_name', with: 'red'
    assert_content 'Red'
  end

  def test_search
    click_on 'People'
    click_on 'Search'
    assert_no_autocomplete 'user_name', with: 'black'
    autocomplete 'user_name', with: 'aaron'
    assert_content 'Aaron'
  end

end
