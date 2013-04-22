require_relative '../test_helper'

class Me::PagesControllerTest < ActionController::TestCase
  fixtures :users, :pages

  def test_list_pages
    login_as users(:blue)
    get :index
    assert_response :success
  end

  def test_list_page_with_long_title
    title = 'VeryLongTitleWithNoSpaceThatWillBeFarTooLongToFitIntoTheTableColumnAndInTurnBreakTheLayoutUnlessItIsBrokenUsingHiddenHyphens'
    expected = 'VeryLongTitleWithNoS&shy;paceThatWillBeFarToo&shy;LongToFitIntoTheTabl&shy;eColumnAndInTurnBrea&shy;kTheLayoutUnlessItIs&shy;BrokenUsingHiddenHyp&shy;hens'
    FactoryGirl.create :wiki_page, :title => title, :owner => users(:blue)
    login_as users(:blue)
    xhr :get, :index
    assert_response :success
    assert response.body.match(expected)
  end

end
