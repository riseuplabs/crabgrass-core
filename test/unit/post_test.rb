require 'test_helper'

class PostTest < ActiveSupport::TestCase
  fixtures :posts

  def test_with_link
    [:greencloth_link, :auto_link, :html_link].each do |fixture_name|
      assert posts(fixture_name).with_link?,
        "Post fixture '#{fixture_name}' has a link but with_link? says it doesn't."
    end

    fixture_name = :no_link
    refute posts(fixture_name).with_link?,
      "Post fixture '#{fixture_name}' has no link but with_link? says it does."

  end

  def test_prevent_creation_of_spam
    page = pages(:public_wiki)
    user = users(:penguin)
    assert_raises ActiveRecord::RecordInvalid do
      post = page.add_post(user, body: posts(:auto_link).body)
    end
  end

  def test_visitor_comment_without_link
    page = pages(:public_wiki)
    user = users(:penguin)
    post = page.add_post(user, body: posts(:no_link).body)
    assert_empty post.errors
    assert_predicate post, :persisted?
  end

  def test_allow_authorized_comment_with_link
    page = pages(:public_wiki)
    user = users(:gerrard)
    post = page.add_post(user, body: posts(:auto_link).body)
    assert_empty post.errors
    assert_predicate post, :persisted?
  end
end
