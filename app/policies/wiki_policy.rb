class WikiPolicy < ApplicationPolicy

  def show?
    if wiki.profile && wiki.profile.private?
      update?
    else
      user.may?(:view, (wiki.page || wiki.group))
    end
  end

  def update?
    user.may?(:edit, (wiki.page || wiki.group))
  end

  def wiki
    record
  end

end
