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

  def process(name, *args)
    super
  rescue ActiveRecord::RecordNotFound
    if logged_in? and (@group or (@user and @user == current_user))
      url = create_page_url(:type => 'wiki', 'page[owner]' => (@group || @user), 'page[title]' => params[:_page])
      logger.info("Redirect to #{url}")

      # FIXME: this controller isn't fully set-up yet (because usually the request
      #   will be completed in a new controller instance), so redirect_to etc.
      #   won't work.
      return [302, { 'Location' => url }, []]

      #warning :thing_not_found.t(:thing => :page.t)
    else
      #set_language do
      # is it required to set the language here?
      raise_not_found(:page.t)
    end
  end

  protected

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
    page_handle = params[:_page]
    context = params[:_context]

    if context
      if context =~ /\ /
        # we are dealing with a committee!
        context.sub!(' ','+')
      end
      @group = Group.find_by_name(context)
      @user  = User.find_by_login(context) unless @group
    end

    if page_handle =~ /[ +](\d+)$/
      # if page handle ends with [:space:][:number:] then find by page id.
      # (the url actually looks like "page-title+52", but pluses are interpreted
      # as spaces). find by id will always return a globally unique page so we
      # can ignore context
      @page = Page.find( $~[1] )
    elsif @group
      # find just pages with the name that are owned by the group
      # no group should have multiple pages with the same name
      @page = find_page_by_group_and_name(@group, page_handle)
    elsif @user
      @page = @user.pages_owned.where(name: page_handle).first
    else
      @pages = find_pages_with_unknown_context(page_handle)
      if @pages.size == 1
        @page = @pages.first
      elsif @pages.size > 1
        # for now, we don't support this.
        # return controller_for_list_of_pages(page_handle)
      end
    end

    raise ActiveRecord::RecordNotFound.new unless @page
    return controller_for_page(@page)
  end

  # Almost every page is retrieved from the database using this method.
  # (1) first, we attempt to load the page using the page owner directly.
  # (2) if that fails, then we resort to searching the entire
  #     namespace of the group
  #
  # Suppose two groups share a page. Only one can be the owner.
  #
  # When linking to the page from the owner's home, we just
  # do /owner-name/page-name. No problem, everyone is happy.
  #
  # But what link do we use for the non-owner's home? /non-owner-name/page-name.
  # This makes it so the banner will belong to the non-owner and it will not
  # be jarring click on a link from the non-owner's home and get teleported to
  # some other group.
  #
  # In order to make this work, we need the second query that includes all the
  # group participation objects.
  #
  # It is true that we could just do without the first query. It makes it slower
  # when the owner is not the context. However, this first query is much faster
  # and is likely to be used much more often than the second query.
  #
  def find_page_by_group_and_name(group, name)
    Page.where(owner: group).where(name: name).first ||
      Page.for_group(group).where(name: name).first
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
    params[:controller] = page.controller
    new_controller("#{params[:controller].camelcase}Controller")
  end

  private

  ## Link to the action for the form to create a page of a particular type.
  def create_page_url(options={})
    group = options.delete(:group)
    url_for(options.merge(controller: 'pages/create', action: 'new'))
  end
end


