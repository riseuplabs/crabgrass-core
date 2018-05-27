class PostPolicy < ApplicationPolicy

  def create?
    logged_in? && (page_policy.show? || page.public?)
  end

  def update?
    record and
      record.user_id == user.id
  end

  alias destroy? update?

  def twinkle?
    record.discussion.page and
      page_policy.show? and
      user.id != record.user_id
  end

  protected

  def page_policy
    Pundit.policy!(user, page)
  end

  def page
    record.discussion.page
  end
end
