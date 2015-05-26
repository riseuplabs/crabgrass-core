#
# We have a problem: every page type has a different controller.
# This means that we either have to declare the controller somehow
# in the route, or use a special dispatch controller that will pass
# on the request to the page's controller.
#
# We have it set up so that we can do both. A static route would look like:
#
#   /groups/riseup/wiki/show/40/
#
# A route using this dispatcher would look like this:
#
#   /riseup/title+40
#
# The second one is prettier, but perhaps it is slower? This remains to be seen.
#
# the idea was taken from:
# http://www.agileprogrammer.com/dotnetguy/archive/2006/07/09/16917.aspx
#
# the dispatcher handles urls in the form:
#
# /:context/:page/:page_action/:id
#
# :context can be a group name or user login
# :page can be the name of the page or "#{title}+#{page_id}"
# :page_action is the action that should be passed on to the page's controller
# :id is just there as a catch all id for extra fun in case the
#     page's controller wants it.
#

class ContextPagesController < DispatchController

  def process(*)
    super
  rescue ActiveRecord::RecordNotFound
    warning :thing_not_found.t(thing: :page.t)
    redirect_to_new_page || raise_not_found
  end

  protected

  def redirect_to_new_page
    return unless logged_in?

    new_page_owner = @group if current_user.may?(:edit, @group)
    new_page_owner ||= (@user if (@user == current_user ))
    return unless new_page_owner

    title = params[:id].split('+')[0...-1].join(' ').humanize
    url = page_creation_url owner: new_page_owner,
      type: :wiki,
      page: { title: params[:id].humanize }
    logger.info("Redirect to #{url}")

    # FIXME: this controller isn't fully set-up yet (because usually the request
    #   will be completed in a new controller instance), so redirect_to etc.
    #   won't work.
    return [302, { 'Location' => url }, []]
  end

  #
  # attempt to find a page by its name, and return a new instance of the
  # page's controller.
  #
  # there are possibilities:
  #
  # - if we can find a unique page, then show that page with the correct controller.
  # - if we get a list of pages
  #   - show either a list of public pages (if not logged in)
  #   - a list of pages current_user has access to
  # - if we fail entirely, show the page not found error.
  #

  def find_controller
    page_handle = params[:id]
    context = params[:context_id]

    if context
      if context =~ /\ /
        # we are dealing with a committee!
        context.sub!(' ','+')
      end
      @group = Group.find_by_name(context)
      @user  = User.find_by_login(context) unless @group
      page_context = @group || @user
    end

    if page_handle =~ /[ +](\d+)$/
      # if page handle ends with [:space:][:number:] then find by page id.
      # (the url actually looks like "page-title+52", but pluses are interpreted
      # as spaces). find by id will always return a globally unique page so we
      # can ignore context
      @page = Page.find( $~[1] )
    elsif page_context
      @page = page_context.find_page(page_handle)
    else
      @pages = find_pages_with_unknown_context(page_handle)
      if @pages.size == 1
        @page = @pages.first
      elsif @pages.size > 1
        # for now, we don't support this.
        # return controller_for_list_of_pages(page_handle)
      end
    end

    controller_for_page(@page) || raise_not_found
  end

  def find_pages_with_unknown_context(name)
    if logged_in?
      options = options_for_me
    else
      options = options_for_public
    end
    Page.paginate_by_path ["name",name], options.merge(pagination_params)
  end

  #def controller_for_list_of_pages(name)
  #  params[:action] = 'index'
  #  params[:search] = {:text => name}
  #  params[:controller] = 'search'
  #  SearchController.new()
  #end

  def controller_for_page(page)
    return unless page
    new_controller page.controller
  end

  private

  ## Link to the action for the form to create a page of a particular type.
  def create_page_url(options={})
    group = options.delete(:group)
    url_for(options.merge(controller: 'pages/create', action: 'new'))
  end
end


