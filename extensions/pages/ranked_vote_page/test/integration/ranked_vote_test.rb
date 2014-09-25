require 'javascript_integration_test'

class RateManyPageTest < JavascriptIntegrationTest
  include Integration::Possibility

  def setup
    super
    own_page :ranked_vote_page
    login
    click_on own_page.title
  end

  def test_initial_option
    assert_page_header
    click_on 'Add new possibility'
    option, description = add_possibility
    click_on 'Done'
    assert_no_content description
    click_on option
    assert_content description
    # There is currently no way to delete an option
    # and the edit button does not work.
    # click_on 'delete'
    # assert_no_content option
  end

  def test_voting
    assert_page_header
    click_on 'Add new possibility'
    option, description = add_possibility
    within '#sort_list_voted' do
      assert_content 'None'
    end
    option_li = find('#sort_list_unvoted li.possible')
    option_li.drag_to find('#sort_list_voted')
    within '#sort_list_voted' do
      assert_no_content 'None'
    end
  end
end
