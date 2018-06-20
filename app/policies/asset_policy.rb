class AssetPolicy < ApplicationPolicy
  def show?
    asset.try.public? || user.may?(:view, asset)
  end

  def destroy?
    user.may?(:admin, asset)
  end

  def asset
    record
  end
end
