class PostPolicy < ApplicationPolicy

  def create?
    logged_in? && (page_policy.show? || page.public?)
  end

  def update?
    post and
      post.user_id == user.id
  end

  alias destroy? update?

  def twinkle?
    post.discussion.page and
      page_policy.show? and
      user.id != post.user_id
  end

  protected

  def page_policy
    Pundit.policy!(user, page)
  end

  def post
    record
  end

  def page
    post.discussion.page
  end
end
