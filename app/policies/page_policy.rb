class PagePolicy < ApplicationPolicy
  # public pages do not require a login in the controller
  # but the permission will still be checked here.
  # So we need to make sure users who do not have explicit
  # access the page can still see it if it's public.
  def show?
    record.public? || user.may?(:view, record)
  end

  def new?
    logged_in?
  end

  def create?
    admin?
  end

  def update?
    user.may?(:edit, record)
  end

  def admin?
    user.may?(:admin, record)
  end

  def print?
    show?
  end
end
