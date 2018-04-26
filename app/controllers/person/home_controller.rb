class Person::HomeController < Person::BaseController
  guard :may_show_home?
  layout 'sidecolumn'

  #
  # called by DispatchController
  #
  def initialize(options = {})
    super()
    @user = options[:user]
  end

  def show
    @profile = @user.profiles.public
  end
end
