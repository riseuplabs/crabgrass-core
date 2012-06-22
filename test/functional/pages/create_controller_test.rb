require File.dirname(__FILE__) + '/../../test_helper'

class Pages::CreateControllerTest < ActionController::TestCase

  def setup
    @user = User.make
  end

  def test_create_page_for_group
    @group = Group.make
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

