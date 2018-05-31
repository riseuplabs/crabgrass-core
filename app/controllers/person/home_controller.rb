class Person::HomeController < Person::BaseController
  layout 'sidecolumn'

  #
  # called by DispatchController
  #
  def initialize(options = {})
    super()
    @user = options[:user]
  end
  hide_action :initialize

  def show
    authorize @user
    @profile = @user.profiles.public
  end
end
