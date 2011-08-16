class Groups::HomeController < Groups::BaseController

  layout 'sidecolumn'

  before_filter :authorized?

  def show
  end

end

