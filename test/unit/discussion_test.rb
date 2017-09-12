require 'test_helper'

class DiscussionTest < ActiveSupport::TestCase
  def test_creation
    discussion = Discussion.create
    post       = discussion.posts.create(body: 'hi', user: users(:blue))
    assert post.valid?, format('post should be valid (%s)', post.errors.full_messages.to_s)
    assert discussion.valid?, format('discussion should be valid (%s)', discussion.errors.full_messages.to_s)

    post = discussion.posts.create(body: 'hi', user: users(:blue))
    assert discussion.reload.posts_count == 2
  end

  def test_creation_in_memory
    disc = Discussion.new(post: { body: 'x', user: users(:blue) })
    assert_equal 'x', disc.posts.first.body
    disc.save!
    disc.reload
    assert_equal 'x', disc.posts.first.body
  end

  def test_with_page
    page = Page.find 1
    user = users(:red)
    post = nil

    assert_nothing_raised do
      Post.create!(page, user, body: 'hi')
    end
    assert_nothing_raised do
      post = Post.create!(page, user, body: 'hi')
    end
    assert_equal 2, page.discussion.reload.posts_count
    assert_equal 2, page.discussion.posts.size

    assert_equal user, page.discussion.replied_by
    assert_equal post, page.discussion.last_post
  end

  def test_associations
    assert check_associations(Post)
    assert check_associations(Discussion)
  end

  def test_discussion_update
    discussion = Discussion.create!

    post1      = Post.create! discussion, users(:blue), body: 'i like giants'
    post2      = Post.create! discussion, users(:blue), body: 'even when they cry'

    assert_equal 2, discussion.reload.posts_count
    assert_last_post_properties post2, discussion

    post2.delete
    assert_equal 1, discussion.reload.posts_count
    assert_last_post_properties post1, discussion

    post2.undelete
    assert_equal 2, discussion.reload.posts_count
    assert_last_post_properties post2, discussion

    post2.destroy
    assert_equal 1, discussion.reload.posts_count
    assert_last_post_properties post1, discussion

    post1.delete
    assert_equal 0, discussion.reload.posts_count
    assert_last_post_properties nil, discussion

    post1.destroy
    assert_equal 0, discussion.reload.posts_count
    assert_last_post_properties nil, discussion
  end

  def assert_last_post_properties(post, discussion)
    if post.nil?
      assert discussion.last_post.nil?
      assert discussion.replied_at.nil?
      assert discussion.replied_by.nil?
      return
    end
    assert_equal post, discussion.last_post
    assert post.updated_at - discussion.replied_at < 1
    assert post.updated_at > discussion.replied_at
    assert_equal post.user, discussion.replied_by
  end
end
