class Groups::HomeController < Groups::BaseController

  layout 'sidecolumn'
  helper 'groups/wikis'
  before_filter 'fetch_wikis'

  def initialize(options = {})
    @group = options[:group]
  end

  before_filter :authorized?

  def show
    @pages = Page.paginate_by_path '/descending/updated_at/limit/30/',
      options_for_group(@group), pagination_params
  end

  protected

  def fetch_wikis
    if current_user.member_of? @group
      @private_wiki = @group.profiles.private.try.wiki
      @public_wiki = @group.profiles.public.try.wiki
      @wiki = just_edited_public_wiki? ? @public_wiki : @private_wiki
      # should we also show a particular wiki if we just viewed the versions of
      # that wiki? seems reasonable
    else
      @wiki = @group.profiles.public.try.wiki
    end
  end

  def just_edited_public_wiki?
    request.referer and
    request.referer == edit_group_wiki_url(@group, @public_wiki)
  end

end

