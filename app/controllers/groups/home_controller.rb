class Groups::HomeController < Groups::BaseController

  layout 'sidecolumn'

  def initialize(options)
    @group = options[:group]
  end

  def show
  end

end

