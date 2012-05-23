#
# All the controllers that have sidebar and popup controls inherit from
# this controller.
#
class Pages::SidebarsController < ApplicationController

  before_filter :fetch_page
  before_filter :login_required
  permissions :pages
  guard :may_edit_page?
  layout nil

  helper 'pages/base', 'pages/sidebar'

  def show
    render :template => 'pages/sidebar/reset'
  end

  protected

  def close_popup
    render :template => 'pages/sidebar/reset'
  end

  def fetch_page
    id = params[:page_id]
    @page = Page.find_by_id(id)
    unless @page
      raise_not_found(:thing_not_found.t(:thing => :page.t))
    end
  end

end
