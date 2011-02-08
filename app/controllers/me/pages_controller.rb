class Me::PagesController < Me::BaseController

  before_render :setup_navigation
  before_filter :parse_path

  def show
  end

  def index
    if request.xhr?
      if params[:add]
        @add_segment = parse_filter_path(params[:add])
        @path.merge!(@add_segment)
      elsif params[:remove]
        @remove_segment = parse_filter_path(params[:remove])
        @path.remove!(@remove_segment)
      end
    end
    @pages = Page.paginate_by_path(@path, options_for_me, pagination_params)
  end

  protected

  def setup_navigation
    @local_navigation = [
      {:active => true, :html => {:partial => 'me/pages/search_controls_active'}},
      {:active => false, :html => {:partial => 'me/pages/search_controls_possible'}}
    ]
  end

  def parse_path
    if params[:path].any?
      @path = parse_filter_path(params[:path])
    elsif params[:filter]
      @path = parse_hash_filter_path(params[:filter])
    else
      @path = parse_filter_path([])
    end
  end

end

