class People::HomeController < People::BaseController

  layout 'sidecolumn'
  guard :show => :may_show_person?

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

