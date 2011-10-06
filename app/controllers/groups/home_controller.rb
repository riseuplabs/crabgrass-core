class Groups::HomeController < Groups::BaseController

  layout 'sidecolumn'
  def initialize(options = {})
    @group = options[:group]
  end

  before_filter :authorized?

  def show #redo
    @profile = @group.profiles.public
  end

end

