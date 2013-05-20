require_relative '../test_helper'

class Me::PagesControllerTest < ActionController::TestCase
  fixtures :users, :pages, :user_participations

  def test_get_index_view
    login_as users(:blue)
    get :index
    assert_response :success
  end

  def test_list_pages
    login_as users(:blue)
    xhr :post, :index
    assert_response :success
  end

  def test_filter_by_own_pages
    pending "filter by me not implemented yet" do
      login_as users(:blue)
      xhr :post, :index, add: "owned-by-me"
      assert_response :success
      assert pages = assigns(:pages)
      assert_nil pages.detect{|page| page.owner != users(:blue)}
    end
  end

  def test_filter_by_created_by_me
    login_as users(:blue)
    xhr :post, :index, add: "created-by-me"
    assert_response :success
    assert pages = assigns(:pages)
    assert_nil pages.detect{|page| page.created_by != users(:blue)}
  end

  def test_list_page_with_long_title
    title = 'VeryLongTitleWithNoSpaceThatWillBeFarTooLongToFitIntoTheTableColumnAndInTurnBreakTheLayoutUnlessItIsBrokenUsingHiddenHyphens'
    expected = 'VeryLongTitleWithNoS&shy;paceThatWillBeFarToo&shy;LongToFitIntoTheTabl&shy;eColumnAndInTurnBrea&shy;kTheLayoutUnlessItIs&shy;BrokenUsingHiddenHyp&shy;hens'
    page = FactoryGirl.build :wiki_page, :title => title, :owner => users(:blue)
    Page.expects(:paginate_by_path).returns([page])
    login_as users(:blue)
    xhr :get, :index
    assert_response :success
    assert assigns(:pages).include?(page)
    assert response.body.include?(expected), "Expected #{response.body} to include #{expected}."
  end

end
