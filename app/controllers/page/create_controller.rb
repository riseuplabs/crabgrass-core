#
# Page definitions can define their own custom creation controllers.
# Here is the default one.
#
# Routes:
#
#  GET new_page_path
#     /pages/create/:owner/:type
#
#  POST create_page_path
#     /pages/create/:owner/:type
#
# (the two paths are the same... the action destinct.)

class Page::CreateController < ApplicationController
  include Common::Tracking::Action

  before_filter :login_required
  before_filter :init_options, :set_owner, :catch_cancel
  after_action :verify_authorized, only: :create
  helper 'page/share', 'page/owner', 'page/creation'
  track_actions :create

  #
  # if there is any error in the 'create' action, call the 'new' action
  # to setup and display the view. useful for subclassing.
  #
  rescue_render create: :new

  def new
    @page = build_new_page! if page_type.present?
    render_new_template
  end

  def create
    @page = build_new_page!
    authorize @page
    @page.save!
    redirect_to page_url(@page)
  end

  # if the page controller is call by our custom DispatchController,
  # objects which have already been loaded will be passed to the tool
  # via this initialize method.
  def initialize(seed = {})
    super()
    @user  = seed[:user]   # the user context, if any
    @group = seed[:group]  # the group context, if any
    @page  = seed[:page]   # the page object, if already fetched
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
      redirect_to new_page_url(params.slice(:owner))
      false
    else
      true
    end
  end

  #
  # options for the form
  #
  def init_options
    @form_sections = %w[title summary tags]
    @multipart     = false
    true
  end

  def set_owner
    # owner from form
    owner_param = params[:page].delete(:owner) if params[:page].present?
    # owner from context
    owner_param ||= params[:owner]
    case owner_param
    when 'me'
    when current_user.login
      @owner = current_user
    else
      group_from_param  = Group.find_by_name(owner_param)
      if current_user.may?(:edit, group_from_param) or group_from_param.try.access?(public: :view)
        @owner = group_from_param
      end
    end
  end

  def track_action
    super :create_page, group: @owner
    @page.user_participations.each do |part|
      super('update_user_access', participation: part)
    end
    @page.group_participations.each do |part|
      super('update_group_access', participation: part)
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
    render template: 'page/create/new'
  end

  #  def create_page
  #    begin
  #      # create basic page instance
  #      @page = build_new_page

  #      # setup the data (done by subclasses)
  #      @data = build_page_data
  #      raise ActiveRecord::RecordInvalid.new(@data) if @data and !@data.valid?

  #      # save the page (also saves the data)
  #      @page.data = @data
  #      @page.save!

  #      # success!
  #      return redirect_to(page_url(@page))

  #    rescue exc
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
  def build_new_page!
    page_type.build!(build_params)
  end

  def build_params
    page_params.merge access: access_param,
                      share_with: params[:recipients],
                      owner: @owner,
                      user: current_user
  end

  def page_params
    params.fetch(:page, {}).permit(:title, :summary, :tag_list)
  end

  def access_param
    access = page_params[:access].to_s
    if %w[admin edit view].include?(access)
      access.to_sym
    else
      Conf.default_page_access
    end
  end

  def param_to_page_class(param)
    Page.param_id_to_class(param) if param
  end

  # def extra_form_sections(options)
  #  @extra_form_sections << options[:add] if options[:add]
  #  @extra_form_sections.delete(options[:remove) if options[:remove]
  # end
  #
  # def remove_form_section(section)
  #  @basic_form_sections.delete(section)
  # end

  #  # returns a new data object for page initialization.
  #  # subclasses override this to build their own data objects
  #  def build_page_data
  #    # if something goes terribly wrong with the data do this:
  #    # @page.errors.add :base, I18n.t(:terrible_wrongness)
  #    # raise ActiveRecord::RecordInvalid.new(@page)
  #    # return new data if everything goes well
  #  end

  #  def destroy_page_data
  #    if @data and !@data.new_record?
  #      @data.destroy
  #    end
  #  end

  def setup_context
    case @owner
    when current_user
      @context = Context::Me.new(current_user)
    when Group
      @context = Context::Group.new(@owner)
    end
    super
  end
end
