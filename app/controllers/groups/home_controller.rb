class Groups::HomeController < Groups::BaseController

  skip_before_filter :login_required
  before_filter :authorized?
  guard :may_show_group?
  before_filter :fetch_wikis

  layout 'sidecolumn'
  helper 'wikis/base', 'wikis/sections'
  permission_helper 'wikis'
  javascript 'upload', 'wiki'
  stylesheet 'wiki_edit', 'upload'

  def initialize(options = {})
    super()
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
    end
    @public_wiki = @group.public_wiki
  end

  #helper_method :coming_from_wiki?
  # will return true if we came from the wiki editor, versions or diffs
  #def coming_from_wiki?(wiki)
  #  wiki and params[:wiki_id].to_i == wiki.id
  #end

end

