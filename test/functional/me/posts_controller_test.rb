require 'test_helper'

class Me::PostsControllerTest < ActionController::TestCase
  def test_list_all_posts_in_discussion
    me = users(:blue)
    you = users(:red)
    login_as me
    Message.send from: me, to: you, body: 'test message'
    discussion = me.discussions.from_user(you).first
    get :index, discussion_id: you.login
    assert_response :success
    assert_equal discussion, assigns(:discussion)
    assert_equal you, assigns(:recipient)
  end

  def test_no_error_on_empty_discussion
    me = users(:gerrard)
    you = users(:green)
    login_as me
    get :index, discussion_id: you.login
    assert_response :success
    assert_equal [], assigns(:posts)
  end

  def test_delete_post
    me = users(:blue)
    you = users(:red)
    post = Message.send from: me, to: you, body: 'test message'
    login_as me
    assert_difference 'Post.count', -1 do
      xhr :delete, :destroy, discussion_id: you.login, id: post
      assert_response :success
    end
  end

  def test_delete_post_without_js
    me = users(:blue)
    you = users(:red)
    post = Message.send from: me, to: you, body: 'test message'
    login_as me
    assert_difference 'Post.count', -1 do
      delete :destroy, discussion_id: you.login, id: post
      assert_response :redirect
    end
  end
end
