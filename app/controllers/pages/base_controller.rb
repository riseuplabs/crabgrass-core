#
# The abstract super-class for the main controller of each page type.
#

class Pages::BaseController < ApplicationController

  public

  layout :choose_layout
  permissions :pages, :object => 'page'
  permissions :posts, :object => 'post'
  permissions 'groups/memberships', 'groups/base'    # required to show the banner if page is owned by a group.

  #stylesheet 'page_creation', :action => :create
  #javascript 'page'
  #permissions 'pages', 'posts'
  #helper 'groups', 'autocomplete', 'base_page/share', 'page_history'

  helper 'pages/base', 'pages/sidebar'

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

  include "pages/before_filters".camelize.constantize  # why doesn't "include Pages::BeforeFilters" work? 

  ##
  ## CONSTRUCTOR
  ##
 
  # if the page controller is call by our custom DispatchController,
  # objects which have already been loaded will be passed to the tool
  # via this initialize method.
  def initialize(seed={})
    super()
    @user  = seed[:user]   # the user context, if any
    @group = seed[:group]  # the group context, if any
    @page  = seed[:page]   # the page object, if already fetched
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

  def new_options
    PageOptions.new(*OPTIONS.values)
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

