class Group::FederatingPolicy < ApplicationPolicy

  # for now we do not allow directly destroying the federating
  # The helper will use a request instead.
  def destroy?
    false
  end

  protected

  delegate :group, :network, to: :record

end
