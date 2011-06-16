class Me::PagesController < Me::BaseController

  include_controllers 'common/page_search'

  def show
  end

  #
  # see controller/common/page_search.rb
  #
  def index
    @path  = apply_path_modifiers( parsed_path() )
    @pages = Page.paginate_by_path(@path, options_for_me, pagination_params)
    # note: pagination_params is used just for defaults, pagination is done through @path.
    render :template => 'common/pages/search/index'
  end

  protected

  def setup_navigation(nav)
    nav[:local] = [
      {:active => true,  :visible => true, :html => {:partial => 'common/pages/search/controls_active'}},
      {:active => false, :visible => true, :html => {:partial => 'common/pages/search/controls_possible'}}
    ]
  end

  # 
  # the common page search code relies on this being defined
  #
  def page_search_path(*args)
    me_pages_path(*args)
  end

end

