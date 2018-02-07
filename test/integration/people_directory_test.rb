require 'javascript_integration_test'

class PeopleDirectoryTest < JavascriptIntegrationTest
  fixtures :users, 'castle_gates/keys'

  def setup
    super
    @user = users(:blue)
  end

  def test_contacts
    login
    click_on 'People'
    autocomplete 'q', with: 'orange'
    within '#user_list' do
      assert_no_content 'Purple!'
      assert_content 'Orange!'
    end
    assert_no_autocomplete 'q', with: 'red'
  end

  def test_peers
    login
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
    login
    click_on 'People'
    find('#column_left').click_on 'Everybody'
    within '#user_list' do
      assert_no_content 'Blue!'
    end
    assert_no_autocomplete 'q', with: 'black'
    autocomplete 'q', with: 'blue'
    within '#user_list' do
      assert_content 'Blue!'
    end
    autocomplete 'q', with: 'aaron'
    within '#user_list' do
      assert_content 'Aaron!'
      assert_no_content 'Blue!'
    end
  end

  def test_logged_out
    visit '/'
    click_on 'People'
    assert_content 'Login Required'
  end
end
