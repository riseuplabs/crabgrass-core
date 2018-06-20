class WikiPolicy < ApplicationPolicy

  def show?
    if wiki.profile && wiki.profile.private?
      update?
    else
      container_policy.show?
    end
  end

  def update?
    user.may?(:edit, (wiki.page || wiki.group))
  end

  protected

  def wiki
    record
  end

  def container_policy
    Pundit.policy!(user, wiki.page || wiki.group)
  end
end
