class Groups::HomeController < Groups::BaseController

  skip_before_filter :login_required
  before_filter :authorized?
  guard :may_show_group?
  before_filter :fetch_wikis

  layout 'sidecolumn'
  helper 'groups/wikis', 'wikis/base', 'wikis/sections'
  permission_helper 'wikis'
  javascript :upload
  stylesheet 'wiki_edit', 'upload'

  def initialize(options = {})
    @group = options[:group]
  end


  def show
    @pages = Page.paginate_by_path '/descending/updated_at/limit/30/',
      options_for_group(@group), pagination_params
  end

  protected

  def fetch_wikis
    if may_edit_group?
      @private_wiki = @group.private_wiki
      @public_wiki = @group.public_wiki
      @wiki = coming_from_wiki?(@public_wiki) || !@private_wiki ? @public_wiki : @private_wiki
    else
      @wiki = @group.public_wiki
    end
  end

  helper_method :coming_from_wiki?
  # will return true if we came from the wiki editor, versions or diffs
  def coming_from_wiki?(wiki)
    wiki and params[:wiki_id].to_i == wiki.id
  end

end

