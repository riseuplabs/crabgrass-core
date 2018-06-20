class RequestPolicy < ApplicationPolicy

  def create?
    record.may_create?(user)
  end

end
