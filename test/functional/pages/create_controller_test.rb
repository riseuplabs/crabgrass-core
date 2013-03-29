require_relative '../../test_helper'

class Pages::CreateControllerTest < ActionController::TestCase

  def setup
    @user  = FactoryGirl.create(:user)
  end

  def test_new_page_view
    login_as @user
    get :new, :owner => 'me', :type => "wiki"
    assert_equal assigns(:owner), @user
  end


  def test_create_page_for_myself
    login_as @user
    assert_difference "WikiPage.count" do
      post :create,
        :owner => 'me',
        :page => {:title => 'title'},
        :type => "wiki",
        :page_type => "WikiPage"
    end
    assert_equal @user, Page.last.owner
    assert Page.last.users.include? @user
  end

  def test_create_page_for_group
    @group  = FactoryGirl.create(:group)
    login_as @user
    assert_difference "WikiPage.count" do
      post :create,
        :owner => @group.name,
        :page => {:title => 'title'},
        :type => "wiki",
        :page_type => "WikiPage"
    end
    assert_equal @group, Page.last.owner
    assert Page.last.users.include? @user
  end
end

