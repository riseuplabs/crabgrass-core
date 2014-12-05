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
    click_link 'Add new possibility'
    option, description = add_possibility
    click_link 'Add new possibility' # close
    assert_content option
    assert_no_content description
    click_on option
    assert_content description
    click_on 'Delete'
    assert_no_content option
  end

  def test_voting
    click_link 'Add new possibility'
    option, description = add_possibility
    click_link 'Add new possibility' # close
    choose 'good'
    within('.possibles') do
      assert_content @user.login
    end
  end


end
