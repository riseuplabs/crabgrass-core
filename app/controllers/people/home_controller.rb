class People::HomeController < People::BaseController

  layout 'sidecolumn'

  #
  # called by DispatchController
  #
  def initialize(options={})
    super()
    @user = options[:user]
  end

  def show
    @profile = @user.profiles.public
  end

end

