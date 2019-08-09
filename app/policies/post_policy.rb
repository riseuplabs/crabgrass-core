class PostPolicy < ApplicationPolicy

  def create?
    logged_in? && (page_policy.show? || page.public?)
  end

  def update?
    post &&
      post.user_id == user.id
  end

  def destroy?
    update? || (admin? && comment_by_visitor_on_public_page?)
  end

  def twinkle?
    page &&
      page_policy.show? &&
      user.id &&
      user.id != post.user_id
  end

  protected

  def admin?
    page_policy.admin?
  end

  def comment_by_visitor_on_public_page?
    page &&
      page.public? &&
      !post.user.may?(:view, page)
  end

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
