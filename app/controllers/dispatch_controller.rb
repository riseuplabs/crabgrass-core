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
#
# TODO: I think the dispatchController breaks flash hash. Fix it!
#

class DispatchController < ApplicationController

  # this is *not* an action, but the 'dispatch' method from ActionController::Metal
  # The only change here is that we don't return to_a(), but instead whatever
  # process() returns.
  def dispatch(name, request, response = ActionDispatch::Response.new)
    @_request = request
    @_env = request.env
    @_env['action_controller.instance'] = self
    process(name)
  rescue Exception => exception
    @_response ||= response
    @_response.request ||= request
    # keep regular rescue_from behaviour, even though we're never calling an action
    # in this controller (taken from ActionController::Rescue#process_action)
    rescue_with_handler(exception) || raise(exception)
    # return "regular" response
    to_a
  end

  # instead of processing the action ('name' is always :dispatch here), we find the
  # right controller and call 'dispatch' there.
  def process(name, *args)
    begin
      flash.keep
      load_current_site
      find_controller.dispatch(params[:action], request)
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
        #end
      end
    end
  end

  private

  def load_current_site; current_site; end

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

    if page_handle.nil?
      return controller_for_group(@group) if @group
      return controller_for_people if @user
      raise ActiveRecord::RecordNotFound.new
    elsif page_handle =~ /[ +](\d+)$/
      # if page handle ends with [:space:][:number:] then find by page id.
      # (the url actually looks like "page-title+52", but pluses are interpreted
      # as spaces). find by id will always return a globally unique page so we
      # can ignore context
      @page = find_page_by_id( $~[1] )
    elsif @group
      # find just pages with the name that are owned by the group
      # no group should have multiple pages with the same name
      @page = find_page_by_group_and_name(@group, page_handle)
    elsif @user
      @page = find_page_by_user_and_name(@user, page_handle)
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

  # create a new instance of a controller, and pass it whatever info regarding
  # current group or user context or page object that we have gathered.
  def new_controller(class_name)
    class_name.constantize.new({:group => @group, :user => @user, :page => @page, :pages => @pages})
  end

  def includes(default=nil)
    # for now, every time we fetch a page we suck in all the groups and users
    # associated with the page. we only do this for GET requests, because
    # otherwise it is likely that we will not need the included data.

    # update: i think this is a big waste of time. checking the logs, group
    # and user participations are fetched independently despite this attempt
    # at including them with the page query -elijah

    #if request.get?
    #  [{:user_participations => :user}, {:group_participations => :group}]
    #else
    #  return default
    #end
    nil
  end

  def find_page_by_id(id)
    Page.find_by_id(id.to_i, :include => includes )
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
    Page.find(
      :first, :conditions => [
        'pages.name = ? AND pages.owner_id = ? AND pages.owner_type = ?',
         name, group.id, 'Group'
      ]
    ) or Page.find(
      :first, :conditions => [
         'pages.name = ? AND group_participations.group_id IN (?)',
          name, Group.namespace_ids(group.id)
      ],
      :joins => :group_participations,
      :readonly => false
    )
  end

  #
  # The main method for loading pages that are in a user context.
  #
  # User context is less forgiving then group context. We only return
  # a page if the owner matches exactly.
  #
  def find_page_by_user_and_name(user, name)
    Page.find(
      :first, :conditions => [
        'pages.name = ? AND pages.owner_id = ? AND pages.owner_type = ?',
         name, user.id, 'User'
      ]
    )
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
    if params[:path].empty?
      params[:controller] = page.controller
      params[:action]     = 'show'
      params[:id]         = nil
    else
      path = params[:path].split('/')
      if page.controllers.include?("#{page.controller}_#{path[0]}")
        params[:controller] = "#{page.controller}_#{path[0]}"
        params[:action]     = path[1] || 'index'
        params[:id]         = path[2]
      else
        params[:controller] = page.controller
        params[:action]     = path[0] || 'index'
        params[:id]         = path[1]
      end
    end
    new_controller("#{params[:controller].camelcase}Controller")
  end

  def controller_for_group(group)
    params[:action] = 'show'
    params[:controller] = 'groups/home'
    params[:group_id] = params[:_context]
    new_controller('Groups::HomeController')

    #
    # we used to have different controllers for groups and networks.
    # we might again someday.
    #
    #if group.instance_of? Network
    #  if current_site.network and current_site.network == group
    #    params[:controller] = 'site_network'
    #    new_controller('SiteNetworkController')
    #  else
    #    params[:controller] = 'groups/networks'
    #    new_controller('Groups::NetworksController')
    #  end
    #else
    #  params[:controller] = 'groups/home'
    #  new_controller('Groups::HomeController')
    #end
  end

  def controller_for_people
    params[:action] = 'show'
    params[:controller] = 'people/home'
    params[:person_id] = params[:_context]
    new_controller('People::HomeController')
  end

  private

  ## Link to the action for the form to create a page of a particular type.
  def create_page_url(options={})
    group = options.delete(:group)
    url_for(options.merge(:controller => 'pages/create', :action => 'new'))
  end

end
