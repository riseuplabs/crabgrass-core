class Me::PagesController < Me::BaseController
  include_controllers 'common/page_search'

  #
  # see controller/common/page_search.rb
  #
  def index
    @path = apply_path_modifiers(parsed_path)
    if request.xhr?
      # note: pagination_params is used just for defaults,
      #       normal pagination is done through @path.
      @pages = Page.paginate_by_path(@path, options_for_me(method: :sphinx), pagination_params).compact
    end
    render template: 'common/pages/search/index', locals: { columns: :updated_with_owner }
  end

  protected

  def setup_navigation(nav)
    nav[:local] = [
      { active: false, visible: true, html: { partial: 'common/pages/search/create' } },
      { active: true,  visible: true, html: { partial: 'common/pages/search/controls_active' } },
      { active: false, visible: true, html: { partial: 'common/pages/search/controls_possible' } }
    ]
    nav
  end

  #
  # the common page search code relies on this being defined
  #
  def page_search_path(*args)
    me_pages_path(*args)
  end
end
