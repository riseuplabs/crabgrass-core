require 'javascript_integration_test'

class PeopleDirectoryTest < JavascriptIntegrationTest

  def setup
    super
    @user = users(:blue)
    login
  end

  def test_contacts
    click_on 'People'
    autocomplete 'q', with: 'orange'
    within '#user_list' do
      assert_no_content 'Purple!'
      assert_content 'Orange!'
    end
    assert_no_autocomplete 'q', with: 'red'
  end

  def test_peers
    click_on 'People'
    click_on 'Peers'
    autocomplete 'q', with: 'red'
    within '#user_list' do
      assert_no_content 'Purple!'
      assert_content 'Red!'
    end
    assert_no_autocomplete 'q', with: 'aaron'
  end

  def test_search
    click_on 'People'
    find('#column_left').click_on 'Search'
    within '#user_list' do
      assert_no_content 'Aaron!'
    end
    assert_no_autocomplete 'q', with: 'black'
    autocomplete 'q', with: 'aaron'
    within '#user_list' do
      assert_content 'Aaron!'
    end
  end

end
