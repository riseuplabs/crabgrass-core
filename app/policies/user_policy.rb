class UserPolicy < ApplicationPolicy

  # show a basic user page if the user allows getting in contact
  def show?
    user.may?(:view, peer) ||
      user.may?(:pester, peer) ||
      user.may?(:request_contact, peer)
  end

  protected

  def peer
    record
  end
end
