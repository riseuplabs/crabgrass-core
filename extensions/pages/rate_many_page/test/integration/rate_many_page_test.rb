require 'javascript_integration_test'

class RateManyPageTest < JavascriptIntegrationTest
  include Integration::Possibility

  def setup
    super
    own_page :rate_many_page
    login
    click_on own_page.title
  end

  def test_initial_option
    assert_page_header
    option, description = add_possibility
    assert_content option
    assert_content description
  end

  def test_delete
    assert_page_header
    option, description = add_possibility
    assert_content option
    find('.poll_possible .trash_16').click
    assert_no_content option
  end

  def test_voting
    option, description = add_possibility
    choose 'good'
    within('li.poll_possible') do
      assert_content @user.login
    end
  end


end
