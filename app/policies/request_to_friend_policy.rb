class RequestToFriendPolicy < ApplicationPolicy
  def create?
    user.may?(:request_contact, peer) &&
      user != peer
  end

  protected

  def peer
    record.recipient
  end
end
