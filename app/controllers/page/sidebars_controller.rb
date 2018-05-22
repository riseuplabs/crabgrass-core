#
# All the controllers that have sidebar and popup controls inherit from
# this controller.
#
class Page::SidebarsController < ApplicationController
  include Common::Tracking::Action

  before_filter :fetch_page
  before_filter :login_required
  layout false

  helper 'page/base', 'page/sidebar'

  def show
    authorize @page, :update?
    render template: 'page/sidebar/reset'
  end

  protected

  def close_popup
    render template: 'page/sidebar/close_popup'
  end

  def refresh_sidebar
    render template: 'page/sidebar/reset'
  end

  def fetch_page
    @page = Page.find(params[:page_id])
    if logged_in?
      # grab the current user's participation from memory
      @upart = @page.participation_for_user(current_user)
    end
  end
end
