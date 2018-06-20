class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def new?
    create?
  end

  def edit?
    update?
  end

  protected

  def logged_in?
    user.is_a?(User::Authenticated)
  end
end
