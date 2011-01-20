#
# The abstract super-class for the main controller of each page type.
#

class Pages::BaseController < ApplicationController

  public

  layout :choose_layout
  #permissions :pages, :object => 'page'
  permissions :pages
  permissions :posts, :object => 'post'
  permissions 'groups/memberships', 'groups/base'    # required to show the banner if page is owned by a group.

  #stylesheet 'page_creation', :action => :create
  #javascript 'page'
  #permissions 'pages', 'posts'
  #helper 'groups', 'autocomplete', 'base_page/share', 'page_history'

  ##
  ## FILTERS
  ## (the order matters!)
  ##

  prepend_before_filter :default_fetch_data

  #append_before_filter :login_or_public_page_required
  append_before_filter :default_setup_options
  append_before_filter :load_posts

  after_filter :update_viewed, :only => :show
  after_filter :save_if_needed, :except => :create
  after_filter :update_view_count, :only => [:show, :edit, :create]

  include "pages/before_filters".camelize.constantize
  #include Pages::BeforeFilters

  ##
  ## CONSTRUCTOR
  ##
 
  # if the page controller is call by our custom DispatchController,
  # objects which have already been loaded will be passed to the tool
  # via this initialize method.
  def initialize(options={})
    super()
    @user = options[:user]   # the user context, if any
    @group = options[:group] # the group context, if any
    @page = options[:page]   # the page object, if already fetched
  end

  ##
  ## ACTIONS
  ##

  def show
  end

  def edit
  end
  
  def update
  end

  def new
  end

  def create
    if params[:cancel]
      redirect_to(new_page_path(:group => params[:group]))
    elsif request.post?
      begin
        @page = build_new_page(
          params[:type],        params[:page],
          params[:recipients],  params[:access]
        )
        # setup the data (done by subclasses)
        @data = build_page_data
        raise ActiveRecord::RecordInvalid.new(@data) if @data and !@data.valid?

        # save the page (also saves the data)
        @page.data = @data
        @page.save!

        redirect_to(page_url(@page))
      rescue Exception => exc
        destroy_page_data
        # in case page gets saved before the exception happens
        @page.destroy unless @page.new_record?
        raise ErrorMessage.new(exc.to_s)
      end
    end
  end

  def destroy
  end

  protected

  # to be overridden by subclasses
  def fetch_data; end
  def setup_options; end

  ##
  ## AUTHORIZATION
  ##

  def authorized
    true
  end

  ##
  ## PAGE OPTIONS
  ## subclasses can control how a page is displayed by changing these values.
  ## they should do so by defining setup_options()
  ##

  OPTIONS = {
    :show_posts  => false,  # show comments for this page?
    :show_reply  => false, # show form to post new comment?
    :show_assets => true,  # show assets for this page?
    :show_tags   => true,  # show tags for this page?
    :show_sidebar => true, # show the page sidebar?
    :title => nil
  }
  PageOptions = Struct.new("PageOptions", *OPTIONS.keys)

  def options
    @options ||= PageOptions.new(*OPTIONS.values)
  end

  ##
  ## PAGE CREATION HELPERS
  ##

  def build_new_page(page_type, page_params, recipients, access)
    raise 'page type required' unless page_type
    page_class = Page.param_id_to_class(page_type)

    page_params = page_params.dup
    page_params[:share_with] = recipients
    page_params[:access] = case access
      when 'admin' then :admin
      when 'edit'  then :edit
      when 'view'  then :view
      else Conf.default_page_access
    end
    page_params[:user] = current_user
    page_class.build!(page_params)
  end

  # returns a new data object for page initialization.
  # subclasses override this to build their own data objects
  def build_page_data
    # if something goes terribly wrong with the data do this:
    # @page.errors.add_to_base I18n.t(:terrible_wrongness)
    # raise ActiveRecord::RecordInvalid.new(@page)
    # return new data if everything goes well
  end

  def destroy_page_data
    if @data and !@data.new_record?
      @data.destroy
    end
  end

  ##
  ## CONTEXT
  ##

  def context
    if @page and @page.owner
      @context = Context.find(@page.owner)
    end
  end

end

