#
# Page definitions can define their own custom creation controllers.
# Here is the default one.
#
# Routes:
#
#  GET new
#     new_page_path
#     /pages/new/:owner/:type
#
#  POST create
#     create_page_path
#     /pages/create/:owner/:type
#

class Pages::CreateController < ApplicationController

  before_filter :login_required, :init_options, :set_owner, :catch_cancel
  helper 'pages/share', 'pages/owner', 'pages/creation'
  permissions :pages
  guard :may_ACTION_page?

  # the page banner has links that the user cannot see when unauthorized, like membership.
  # so, we must load the appropriate permissions from groups.
  permission_helper 'groups/memberships', 'groups/base'

  #
  # if there is any error in the 'create' action, call the 'new' action
  # to setup and display the view. useful for subclassing.
  #
  rescue_render :create => lambda { new }

  def new
    @page = build_new_page! if params[:page]
    render_new_template
  end

  def create
    @page = build_new_page!
    @page.save!
    redirect_to page_url(@page)
  end

  protected

  #
  # before filters
  #

  #
  # if cancel is ever set, return to the start
  #
  def catch_cancel
    if params[:cancel]
      redirect_to new_page_url(:owner => params[:owner])
      return false
    else
      return true
    end
  end

  #
  # options for the form
  #
  def init_options
    @form_sections = ['title', 'summary', 'tags']
    @multipart     = false
    return true
  end

  #
  # for some routes, the owner is in the page_id.
  #
  def set_owner
    unless params[:owner]
      params[:owner] = params[:page_id]
    end
    if params[:owner] == 'me'
      @owner = current_user
    elsif params[:owner].present?
      @owner = Group.find_by_name(params[:owner])
    end
  end

  #
  # helper methods
  #

  #
  # returns a class object for the page type, or a page class proxy object.
  # can be overwritten by subclasses. I would like to call this page_class,
  # but haml already defines a helper with that name.
  #
  def page_type
    @page_type ||= param_to_page_class(params[:type])
  end
  helper_method :page_type

  def render_new_template
    render :template => 'pages/create/new'
  end

#  def create_page
#    begin
#      # create basic page instance
#      @page = build_new_page(params[:page], params[:recipients], params[:access])

#      # setup the data (done by subclasses)
#      @data = build_page_data
#      raise ActiveRecord::RecordInvalid.new(@data) if @data and !@data.valid?

#      # save the page (also saves the data)
#      @page.data = @data
#      @page.save!

#      # success!
#      return redirect_to(page_url(@page))

#    rescue Exception => exc
#      # failure!
#      destroy_page_data
#      # in case page gets saved before the exception happens
#      @page.destroy if @page and !@page.new_record?
#      raise exc
#    end
#  end

  #
  # method to build the unsaved page object, with correct access.
  # used by this controller and subclasses.
  #
  # we may be able to remove the options arg, not sure it is ever used.
  #
  def build_new_page!(options={})
    page_params = options[:page] || params[:page]
    recipients  = options[:recipient] || params[:recipients]
    access      = options[:access] || params[:access]

    page_params = page_params.dup
    page_params[:share_with] = recipients
    page_params[:access] = case access
      when 'admin' then :admin
      when 'edit'  then :edit
      when 'view'  then :view
      else Conf.default_page_access
    end
    page_params[:user] = current_user
    page_params[:owner] ||= @owner
    page_type.build!(page_params)
  end

  def param_to_page_class(param)
    if param
      Page.param_id_to_class(param)
    end
  end

  #def extra_form_sections(options)
  #  @extra_form_sections << options[:add] if options[:add]
  #  @extra_form_sections.delete(options[:remove) if options[:remove]
  #end
  #
  #def remove_form_section(section)
  #  @basic_form_sections.delete(section)
  #end


#  # returns a new data object for page initialization.
#  # subclasses override this to build their own data objects
#  def build_page_data
#    # if something goes terribly wrong with the data do this:
#    # @page.errors.add_to_base I18n.t(:terrible_wrongness)
#    # raise ActiveRecord::RecordInvalid.new(@page)
#    # return new data if everything goes well
#  end

#  def destroy_page_data
#    if @data and !@data.new_record?
#      @data.destroy
#    end
#  end

  def setup_context
    if params[:owner] and params[:owner] != 'me'
      @group = Group.find_by_name(params[:owner])
    end
    if @group
      @context = Context::Group.new(@group)
    else
      @context = Context::Me.new(current_user)
    end
    super
  end

end

