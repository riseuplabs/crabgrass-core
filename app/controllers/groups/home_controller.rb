class Groups::HomeController < Groups::BaseController

  layout 'sidecolumn'
  helper 'groups/wiki'

  def initialize(options = {})
    @group = options[:group]
  end

  before_filter :authorized?

  def show #redo
    @profile = @group.profiles.public
    @wiki = @profile.wiki
  end

end

