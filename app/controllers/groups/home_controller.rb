class Groups::HomeController < Groups::BaseController

  layout 'sidecolumn'
  helper 'groups/wikis'

  def initialize(options = {})
    @group = options[:group]
  end

  before_filter :authorized?

  def show
    @profile = @group.profile
    @wiki = @profile.wiki
    @public_wiki = @group.profiles.public.wiki
  end

end

