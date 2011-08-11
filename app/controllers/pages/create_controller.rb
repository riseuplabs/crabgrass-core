# 
# Page definitions can define their own custom creation controllers.
# Here is the default one.
#
# Routes:
#
#  GET new
#     new_page_path
#     /pages/new/:type
# 
#  POST create
#     create_page_path
#     /pages/create/:type
#

class Pages::CreateController < ApplicationController

  before_filter :login_required
  helper 'pages/share', 'pages/owner'
  permissions 'pages'

  def new
    new_page
  end

  def create
    if params[:cancel]
      redirect_to new_page_url(:group => params[:group], :type => nil)
    else
      create_page
    end
  end

  protected

  #
  # returns a class object for the page type, or a page class proxy object.
  # can be overwritten by subclasses
  #
  def page_class
    param_to_page_class(params[:type]) 
  end
  helper_method :page_class

  def new_page
    @page_class = page_class
    render :template => 'pages/create/new'
  end

  def create_page
    begin
      # create basic page instance
      @page = build_new_page(params[:page], params[:recipients], params[:access])

      # setup the data (done by subclasses)
      @data = build_page_data
      raise ActiveRecord::RecordInvalid.new(@data) if @data and !@data.valid?

      # save the page (also saves the data)
      @page.data = @data
      @page.save!

      # success!
      return redirect_to(page_url(@page))

    rescue Exception => exc
      # failure!
      destroy_page_data
      # in case page gets saved before the exception happens
      @page.destroy if @page and !@page.new_record?
      raise exc
    end
  end

  ##
  ## PAGE CREATION HELPERS
  ##

  def build_new_page(page_params, recipients, access)
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

  def param_to_page_class(param)
    if param
      Page.param_id_to_class(param)
    end
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
  ## DISPLAY
  ##

  def setup_context
    if params[:owner] and params[:owner] != 'me'
      @group = Group.find_by_name(params[:owner])
    end
    if @group
      Context::Group.new(@group)
    else
      Context::Me.new(current_user)
    end
  end

end

