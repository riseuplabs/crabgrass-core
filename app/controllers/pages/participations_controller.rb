# 
# Routes:
#
#  create:  page_participations_path  /pages/:page_id/participations
#  update:  page_participation_path   /pages/:page_id/participations/:id
#

class Pages::ParticipationsController < Pages::SidebarController

  before_filter :login_required
  helper 'pages/participation', 'pages/share'

  # this is used for ajax pagination
  def index
    tab = params[:tab] == 'permissions' ? 'permissions_tab' : 'participation_tab'
    render :update do |page|
      if params[:tab] == 'permissions'
        page.replace_html 'permissions_tab', :partial => 'pages/participation/permissions'
      elsif params[:tab] == 'participation'
        page.replace_html 'participation_tab', :partial => 'pages/participation/participation'
      end
    end
  end

  def update
    if params[:watch]
      watch
    elsif params[:star]
      star
    elsif params[:access]
      access
    end
  end

  def create
    update
  end

  protected

  def watch
    @upart = @page.add(current_user, :watch => params[:watch])
    @upart.save!
    render(:update) {|page| page.replace 'watch_li', watch_line}
  end

  def star
    @upart = @page.add(current_user, :star => params[:star])
    @upart.save!
    render(:update) {|page| page.replace 'star_li', star_line}
  end

  def access
    if params[:access] == 'remove'
      destroy
    else
      @page.add(@participation.entity, :access => params[:access]).save!
      render :update do |page|
        page.replace_html dom_id(@participation), :partial => 'pages/participation/permission_row', :locals => {:participation => @participation.reload}
      end
    end
  end

  ## technically, we should probably not destroy the participations
  ## however, since currently the existance of a participation means
  ## view access, then we need to destory them to remove access.
  def destroy
    if may_remove_participation?(@participation)
      if @participation.is_a? UserParticipation
        @page.remove(@participation.user)
      else
        @page.remove(@participation.group)
      end
    else
      raise ErrorMessage.new(:remove_access_error.t)
    end
    render :update do |page|
      page.hide dom_id(@participation)
    end
  end

  protected

  def fetch_data
    if params[:group]
      @participation = GroupParticipation.find(params[:id]) if params[:id]
    else
      @participation = UserParticipation.find(params[:id]) if params[:id]
    end
  end

  def authorized?
    may_show_page?
  end

end

