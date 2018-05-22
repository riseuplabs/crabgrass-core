class WikiPolicy < ApplicationPolicy

  def show?
    if record.profile && record.profile.private?
      update?
    else
      user.may?(:view, (record.page || record.group))
    end
  end

  def update?
    user.may?(:edit, (record.page || record.group))
  end

end
