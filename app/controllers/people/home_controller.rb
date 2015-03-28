class People::HomeController < People::BaseController

  guard :may_show_home?
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
    track
  end

end

