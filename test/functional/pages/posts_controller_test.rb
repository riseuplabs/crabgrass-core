require_relative '../../test_helper'

class Pages::PostsControllerTest < ActionController::TestCase

  def setup
    @user = FactoryGirl.create :user
    @page = FactoryGirl.create(:page, owner: @user)
  end

  def test_create_post
    login_as @user
    body = "Test Message"
    xhr :post, :create, page_id: @page.id, post: {
      body: body
    }
    assert_response :success
    assert_equal 1, @page.reload.posts.count
    assert_equal body, @page.posts.first.body
  end

  def test_edit_post
    @post = Post.create! @page, @user, {body: "Test Contetn"}
    login_as @user
    xhr :get, :edit, page_id: @page.id, id: @post.id
    assert_response :success
    assert_equal @post, assigns[:post]
  end
end
