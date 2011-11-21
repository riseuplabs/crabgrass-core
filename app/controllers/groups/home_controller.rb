class Groups::HomeController < Groups::BaseController

  layout 'sidecolumn'
  helper 'groups/wikis'

  def initialize(options = {})
    @group = options[:group]
  end

  before_filter :authorized?

  def show
    @profile = @group.profile
    @private_wiki = @profile.wiki
    @public_wiki = @group.profiles.public.wiki
    # have public wiki displayed if that was just edited; otherwise private wiki
    @wiki = (request.referer && (request.referer == edit_group_wiki_url(@group, @public_wiki))) ? @public_wiki : @private_wiki
    # should we also show a particular wiki if we just viewed the versions of that wiki? seems reasonable
  end

end

