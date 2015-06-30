require 'test_helper'

class Pages::PostsControllerTest < ActionController::TestCase

  def setup
    @user = FactoryGirl.create :user
    @page = FactoryGirl.create(:page, owner: @user)
  end

  def test_create_post
    login_as @user
    xhr :post, :create, page_id: @page.id, post: {
      body: body
    }
    assert_successfully_posted_to @page
    assert_history_tracked 'AddComment', Post.last
  end

  def test_edit_post
    @post = Post.create! @page, @user, {body: "Test Contetn"}
    login_as @user
    xhr :get, :edit, page_id: @page.id, id: @post.id
    assert_response :success
    assert_equal @post, assigns[:post]
  end

  def test_post_on_public_page
    public_page = FactoryGirl.create(:page, public: true)
    login_as @user
    xhr :post, :create, page_id: public_page, post: {
      body: body
    }
    assert_successfully_posted_to public_page
    # let's make sure posting a comment does not grant more access...
    assert_nil public_page.user_participations.where(user_id: @user).first.access
    # despite commenting you can only view the page because it is public
    @user.clear_access_cache
    assert !@user.may?(:view, public_page)
  end

  def assert_successfully_posted_to(page)
    assert_response :redirect
    assert_equal 1, page.reload.posts.count
    assert_equal body, page.posts.first.body
    assert_equal @user, page.updated_by
  end

  def assert_history_tracked(subclass_string, item = nil)
    assert history = @page.page_histories.last, "Missing history record"
    assert_equal @user, history.user
    assert_equal "PageHistory::#{subclass_string}", history.class.name
    assert_equal item, history.item if item.present?
  end

  def body
    "Test Message"
  end
end
