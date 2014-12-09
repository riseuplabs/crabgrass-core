require 'javascript_integration_test'

class RankedVoteTest < JavascriptIntegrationTest
  include Integration::Possibility
  include Integration::Navigation

  def setup
    super
    own_page :ranked_vote_page
    login
    click_link own_page.title
  end

  def test_initial_option
    assert_page_header
    click_link 'Add new possibility'
    option, description = add_possibility
    click_link 'Add new possibility' # close
    assert_no_content description
    click_link option
    assert_content description
    find('#content').click_link 'Edit'
    click_button 'Delete'
    assert_no_content option
    wait_for_ajax
  end

  def test_voting
    click_link 'Add new possibility'
    option, description = add_possibility
    click_link 'Add new possibility' # close
    assert_not_voted_yet
    vote
    assert_voted
    finish_voting
    assert_first_choice_of(@user, option)
  end


  def test_multiple_options
    click_link 'Add new possibility'
    add_possibility
    option, description = add_possibility
    click_link 'Add new possibility' # close
    click_page_tab 'Show results'
    click_link option
    assert_content description
    click_page_tab 'Edit my vote'
    assert_content option
    vote
    finish_voting
    assert_content 'top pick'
  end

  def vote
    option_li = find('#sort_list_unvoted li.possible', match: :first)
    option_li.drag_to find('#sort_list_voted')
    # returns the option we voted for and also makes sure
    # the vote has been processed
    find('#sort_list_voted li.possible', text: option_li.text)
  end

  def finish_voting
    click_page_tab "Show results"
  end

  def assert_not_voted_yet
    within '#sort_list_voted' do
      assert_content 'None'
    end
  end

  def assert_voted
    within '#sort_list_voted' do
      assert_no_content 'None'
    end
  end

  def assert_first_choice_of(user, option)
    click_link option
    assert_content "first choice of : #{user.login}"
  end
end
