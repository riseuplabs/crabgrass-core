class Person::PagesController < Person::BaseController
  include_controllers 'common/page_search'

  def index
    authorize @user, :show?
    @path  = apply_path_modifiers(parsed_path)
    @pages = Page.paginate_by_path(@path, options_for_user(@user), pagination_params)
    @page_search_navigation = page_search_navigation
    render template: 'common/pages/search/index'
  end

  protected

  def page_search_navigation
    [
      { active: true,  visible: true, html: { partial: 'common/pages/search/controls_active' } },
      { active: false, visible: true, html: { partial: 'common/pages/search/controls_possible' } }
    ]
  end

  #
  # the common page search code relies on this being defined
  #
  def page_search_path(*args)
    person_pages_path(*args)
  end

  #
  # hide filters for the my_pages section
  #
  def show_filter?(filter)
    filter.section != :my_pages
  end
end
