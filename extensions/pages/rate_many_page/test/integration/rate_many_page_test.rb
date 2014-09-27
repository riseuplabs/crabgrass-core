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
    click_on 'Done'
    assert_no_content description
    click_on option
    assert_content description
    click_on 'delete'
    assert_no_content option
  end

  def test_voting
    option, description = add_possibility
    choose 'good'
    within('.possibles') do
      assert_content @user.login
    end
  end


end
