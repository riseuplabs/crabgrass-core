class AssetPolicy < ApplicationPolicy
  def show?
    record.try.public? || user.may?(:view, record)
  end

  def destroy?
    user.may?(:admin, record)
  end
end
