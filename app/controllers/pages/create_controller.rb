# 
# Page definitions can define their own custom creation controllers.
# Here is the default one.
#
# Routes:
#
#  GET new
#     new_page_path
#     /pages/create/new
# 
#  POST new
#     new_page_path
#     /pages/create/new
#

class Pages::CreateController < ApplicationController

  before_filter :login_required
  helper 'pages/share'
  permissions 'pages'

  def new
    if request.post?
      if params[:cancel]
        redirect_to(new_page_path(:group => params[:group], :type => nil))
      else
        create_page
      end
    else
      new_page
    end
  end

  protected

  def new_page
    if params[:type]
      @page_class = param_to_page_class(params[:type])
      #@page = @page_class.build!({})
      #@page.id = 0
    end
  end

  def create_page
    begin
      # create basic page instance
      @page_class = param_to_page_class(params[:type])
      @page = build_new_page(
        @page_class,  params[:page],
        params[:recipients],  params[:access]
      )

      # setup the data (done by subclasses)
      @data = build_page_data
      raise ActiveRecord::RecordInvalid.new(@data) if @data and !@data.valid?

      # save the page (also saves the data)
      @page.data = @data
      @page.save!

      # success!
      redirect_to(page_url(@page))

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

  def build_new_page(page_class, page_params, recipients, access)
    raise 'page type required' unless page_class
    #page_class = param_to_page_class(page_type)

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
    Page.param_id_to_class(param)
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
    @group = Group.find_by_name(params[:group]) if params[:group]
    if @group
      Context::Group.new(@group)
    else
      Context::Me.new(current_user)
    end
  end

end

