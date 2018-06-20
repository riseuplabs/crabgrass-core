class User::GhostPolicy < ApplicationPolicy

  def show?
    false
  end
end
