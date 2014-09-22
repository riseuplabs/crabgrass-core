require 'test_helper'

class RankedVotePageControllerTest < ActionController::TestCase
  fixtures :pages, :users, :user_participations, :polls, :possibles

  def setup
    user = users(:orange)
    login_as user
    @page = FactoryGirl.create :ranked_vote_page, :created_by => user
    @poll = @page.data
  end

  def test_show_empty_redirects
    get :show, :page_id => @page.id
    assert_response :redirect
    assert_redirected_to :action => :edit
  end

  def test_add_possible
    assert_difference '@page.data.possibles.count' do
      post :add_possible, :page_id => @page.id, :possible => {:name => "new option", :description => ""}
    end
  end

  def test_show_with_possible
    @poll.possibles.create do |pos|
      pos.name = "new option"
    end
    get :show, :page_id => @page.id
    assert_response :success
    assert_template 'ranked_vote_page/show'
  end

  def test_edit
    get :edit, :page_id => @page
    assert_response :success
  end

  # TODO: tests for sort, update_possible, edit_possible, destroy_possible,
end
