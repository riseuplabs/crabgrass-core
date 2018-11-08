#
# These are the before and after filters for Page::BaseController.
# They live here because there are so many of them.
#

module Page::BeforeFilters
  protected

  ##
  ## BEFORE FILTERS
  ##

  #
  # a before filter that comes before all the others.
  # allows us to grab the @page before the permissions need to be resolved.
  # subclasses should define 'fetch_data', which this method calls.
  #
  def default_fetch_data
    @page ||= Page.find(params[:page_id] || params[:id])
    raise ErrorNotFound, :page unless @page && policy(@page).show?

    if logged_in?
      # grab the current user's participation from memory
      @upart = @page.participation_for_user(current_user)
    end

    # hook for subclasses to define:
    fetch_data

    true
  rescue ErrorNotFound => e
    @exception = e
    render 'exceptions/show',
           status: 404,
           layout: request.xhr? ? nil : 'notice'
  end

  def default_setup_options
    @options = Page::BaseController::Options.new
    @options.show_assets  = true
    @options.show_tags    = true
    @options.show_tabs    = false
    if request.get?
      @options.show_posts = action?(:show) || action?(:print)
      @options.show_reply = @options.show_posts
      @options.title = @page.title if @page
    end
    setup_options
    true
  end

  # def choose_layout
  #  if action?(:create, :new)
  #    return 'application'
  #  else
  #    return 'page'
  #  end
  # end

  # don't require a login for public pages
  def login_or_public_page_required
    if action_name == 'show' and @page and @page.public?
      true
    else
      login_required
    end
  end

  def load_posts
    if @options.show_posts and request.get? and !@page.nil?
      @posts = @page.posts(page: page_number)
      @post = Post.new if @options.show_reply
    end
  end


  # ensure the page will be reloaded when navigated to in browser history
  # why? because we use a bunch of ajax on the pages - for example when
  # adding comments. It's really odd if these disappear when you navigate
  # back.
  def bust_cache
    response.headers['Cache-Control'] = 'no-cache, no-store, max-age=0, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = 'Fri, 01 Jan 1990 00:00:00 GMT'
  end

  ##
  ## AFTER FILTERS
  ##

  def update_viewed
    if @upart and @page
      @upart.viewed_at = Time.now
      @upart.viewed = true
    end
    true
  end

  def save_if_needed
    @upart.save if @upart and !@upart.new_record? and @upart.changed? and !@upart.readonly?
    @page.save if @page and !@page.new_record? and @page.changed? and !@page.readonly?
    true
  end

  private

  def page_number
    # use params[:posts] for pagination
    page_number = params[:posts].to_i
    page_number if page_number > 0
  end

end
