class MessagePolicy < ApplicationPolicy
  def create?
    user.may?(:pester, recipient)
  end

  protected

  def recipient
    record.recipient
  end
end
