class Groups::HomeController < Groups::BaseController

  layout 'sidecolumn'
  def initialize(options = {})
    @group = options[:group]
  end

  before_filter :authorized?

  def show
  end

end

