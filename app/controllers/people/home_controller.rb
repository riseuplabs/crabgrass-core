class People::HomeController < People::BaseController

  layout 'sidecolumn'

  #
  # called by DispatchController
  #
  def initialize(options)
    @user = options[:user]
  end

  def show
  end

end

