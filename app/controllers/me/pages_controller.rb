class Me::PagesController < Me::BaseController

  before_render :setup_navigation
  before_filter :parse_path
  helper 'page/search'

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
      # @path = parse_filter_path('all') if @path.empty?
    else
      options = options_for_me.merge(:include => :updated_by)
      @pages = Page.paginate_by_path(@path, options, pagination_params)
    end
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
      @path = [] #parse_filter_path(['all'])
    end
  end

  # We are not required to store the current filter path in the session.
  # However, if we don't do this, there are problems with the anchor-based
  # ajax search filters: there is a race condition when you click two
  # checkboxes at once. Both report the their current anchor-based path,
  # but the second one in then overwriting the changes made by the first one.
  #
  # Instead, we can use the session to keep our own record of the current
  # ajax search filter. This does not work well if you are using cookie
  # based sessions.
  #
  #def store_path_in_session?
  # #ActionController.session_store != ActionController::Session::CookieStore
  # return false
  #end

end

