class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def admin?
    false
  end

  def destroy?
    admin?
  end

  protected

  def logged_in?
    user.is_a?(User::Authenticated)
  end
end
