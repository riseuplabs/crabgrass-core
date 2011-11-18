#
# The abstract super-class for the main controller of each page type.
#

class Pages::BaseController < ApplicationController

  public

  layout 'page'
  permissions :pages, :object => 'page'
  permissions :posts, :object => 'post'
  permissions 'groups/members', 'groups/base'    # required to show the banner if page is owned by a group.

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
  ## PAGE OPTIONS
  ## subclasses can control how a page is displayed by changing these values.
  ## they should do so by defining setup_options() and modifying @options member
  ## variable (which is of type Pages::BaseController::Options)
  ##

  class Options
    attr_accessor :show_posts     # show comments for this page?
    attr_accessor :show_reply     # show form to post new comment?
    attr_accessor :show_assets    # show assets for this page?
    attr_accessor :show_tags      # show tags for this page?
    attr_accessor :show_sidebar   # show the page sidebar?
    attr_accessor :show_tabs      # load 'tabs' partial?
    attr_accessor :title          # html title
  end

  ##
  ## CONTEXT
  ##

  def setup_context
    if @page and @page.owner
      if @page.owner == current_user
        Context::Me.new(current_user)
      else
        Context.find(@page.owner)
      end
    end
  end

end

