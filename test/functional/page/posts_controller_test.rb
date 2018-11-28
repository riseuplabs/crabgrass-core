require 'test_helper'

class Page::PostsControllerTest < ActionController::TestCase
  def setup
    @page = pages(:blue_page)
  end

  def test_create_post
    login_as users(:blue)
    xhr :post, :create, page_id: @page.id, post: {
      body: body
    }
    assert_successfully_posted_to @page
    assert_history_tracked 'AddComment', Post.last
  end

  def test_edit_post
    post = Post.create! @page, users(:blue), body: 'Test Content'
    login_as users(:blue)
    xhr :get, :edit, page_id: @page.id, id: post.id
    assert_response :success
    assert_equal post, assigns[:post]
  end

  def test_create_post_with_emoji
    assert_nothing_raised do
      @post = Post.create! @page, users(:blue), body: '😀'
   end
  end

  def test_post_on_public_page
    public_page = FactoryBot.create(:page, public: true)
    login_as users(:blue)
    xhr :post, :create, page_id: public_page, post: {
      body: body
    }
    assert_successfully_posted_to public_page
    # let's make sure posting a comment does not grant more access...
    assert_nil public_page.user_participations.where(user_id: users(:blue)).first.access
    # despite commenting you can only view the page because it is public
    assert !users(:blue).may?(:view, public_page)
  end

  def assert_successfully_posted_to(page)
    assert_response :redirect
    assert_equal 1, page.reload.posts.count
    assert_equal body, page.posts.first.body
    assert_equal users(:blue), page.updated_by
  end

  def test_edit_not_allowed
    post = Post.create! @page, users(:blue), body: 'Test Content'
    login_as users(:red)
    assert_permission_denied do
      xhr :get, :edit, page_id: @page.id, id: post.id
    end
  end

  def test_destroy_not_allowed
    post = Post.create! @page, users(:blue), body: 'Test Content'
    login_as users(:red)
    assert_permission_denied do
      xhr :post, :update, page_id: @page.id, id: post.id, type: :destroy
    end
  end

  def assert_history_tracked(subclass_string, item = nil)
    assert history = @page.page_histories.last, 'Missing history record'
    assert_equal users(:blue), history.user
    assert_equal "Page::History::#{subclass_string}", history.class.name
    assert_equal item, history.item if item.present?
  end

  def body
    'Test Message'
  end
end
