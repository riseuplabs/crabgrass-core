class Me::PagesController < Me::BaseController

  before_render :setup_navigation

  def show
  end

  #
  # see controller_extension/page_search.rb
  #
  def index
    @path  = apply_path_modifiers( page_search_path() )
    @pages = Page.paginate_by_path(@path, options_for_me, pagination_params)
  end

  protected

  def setup_navigation
    @local_navigation = [
      {:active => true,  :visible => true, :html => {:partial => 'me/pages/search_controls_active'}},
      {:active => false, :visible => true, :html => {:partial => 'me/pages/search_controls_possible'}}
    ]
  end

end

