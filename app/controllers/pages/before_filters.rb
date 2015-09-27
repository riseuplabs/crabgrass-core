#
# These are the before and after filters for Pages::BaseController.
# They live here because there are so many of them.
#

module Pages::BeforeFilters

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
    raise_not_found unless may_show_page?

    if logged_in?
      # grab the current user's participation from memory
      @upart = @page.participation_for_user(current_user)
    end

    # hook for subclasses to define:
    fetch_data

    true
  end

  def default_setup_options
    @options = Pages::BaseController::Options.new
    @options.show_assets  = true
    @options.show_tags    = true
    @options.show_sidebar = true
    @options.show_tabs    = false
    if request.get?
      @options.show_posts = action?(:show) || action?(:print)
      @options.show_reply = @options.show_posts
      @options.title = @page.title if @page
    end
    setup_options
    true
  end

  #def choose_layout
  #  if action?(:create, :new)
  #    return 'application'
  #  else
  #    return 'page'
  #  end
  #end

  # don't require a login for public pages
  def login_or_public_page_required
    if action_name == 'show' and @page and @page.public?
      true
    else
      return login_required
    end
  end

  def load_posts
    if @options.show_posts and request.get? and !@page.nil?
      # use params[:posts] for pagination
      @posts = @page.posts(page: params[:posts])
      if @options.show_reply
        @post = Post.new
      end
    end
  end

  # ensure the page will be reloaded when navigated to in browser history
  # why? because we use a bunch of ajax on the pages - for example when
  # adding comments. It's really odd if these disappear when you navigate
  # back.
  def bust_cache
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
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

  def update_view_count
    return true unless @page and @page.id
    action = case params[:action]
      when 'create' then :edit
      when 'edit' then :edit
      when 'show' then :view
    end
    return true unless action

    group = nil
    user  = nil
    if current_site.tracking?
      if @group
        group = @group
      elsif @page.owner_is?(Group)
        group = @page.owner
      end
      if @page.owner_is?(User)
        user = @page.owner
      end
    end
    Tracking::Page.insert(
      page: @page, current_user: current_user, action: action,
      group: group, user: user
    )
    true
  end

end

