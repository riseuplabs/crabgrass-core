class MessagePolicy < ApplicationPolicy
  def create?
    user != recipient &&
      user.may?(:pester, recipient)
  end

  protected

  def recipient
    record.recipient
  end
end
