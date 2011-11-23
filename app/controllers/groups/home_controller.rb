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
      @private_wiki = @group.profiles.private.wiki
      @public_wiki = @group.profiles.public.wiki
      @wiki = coming_from_wiki?(@public_wiki) ? @public_wiki : @private_wiki
    else
      @wiki = @group.profiles.public.wiki
    end
  end

  helper_method :coming_from_wiki?
  # will return true if we came from the wiki editor, versions or diffs
  def coming_from_wiki?(wiki)
    return unless wiki
    request.referer == edit_group_wiki_url(@group, wiki) or
    request.referer.index(root_url + 'wikis')
  end

end

