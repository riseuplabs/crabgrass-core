class Groups::HomeController < Groups::BaseController

  helper 'widget/wiki'
  permissions 'wiki'
  #permissions 'widget/wiki'
  layout 'sidecolumn'
  def initialize(options = {})
    @group = options[:group]
  end

  before_filter :authorized?

  def show #redo
    @profile = @group.profiles.public
    # just have one wiki for now, not separate private/public
    @profile.create_wiki unless @profile.wiki
    @wiki = @profile.wiki
  end

end

