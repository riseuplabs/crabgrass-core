#
# Routes:
#
#  create:  page_participations_path  /pages/:page_id/participations
#  update:  page_participation_path   /pages/:page_id/participations/:id
#

class Pages::ParticipationsController < Pages::SidebarsController

  guard :may_show_page?, actions: [:update, :create]
  helper 'pages/participation', 'pages/share'

  before_filter :fetch_data
  track_actions :update

  # this is used for ajax pagination
  def index
  end

  def update
    if params[:access]
      raise_denied unless may_admin_page?
      access
    elsif params[:watch]
      watch
    elsif params[:star]
      star
    end
  end

  def create
    update
  end

  protected

  def watch
    @upart = @page.add(current_user, watch: params[:watch])
    @upart.save!
    render(:update) {|page| page.replace 'watch_li', watch_line}
  end

  def star
    @upart = @page.add(current_user, star: params[:star])
    @upart.save!
    render(:update) {|page| page.replace 'star_li', star_line}
  end

  def access
    if params[:access] == 'remove'
      destroy
    else
      @page.add(participation.entity, access: params[:access]).save!
      render :update do |page|
        page.replace_html dom_id(participation), partial: 'pages/participations/permission_row', locals: {participation: participation.reload}
      end
    end
  end

  ## technically, we should probably not destroy the participations
  ## however, since currently the existance of a participation means
  ## view access, then we need to destory them to remove access.
  def destroy
    if may_remove_participation?(participation)
      if participation.is_a? UserParticipation
        @page.remove(participation.user)
      else
        @page.remove(participation.group)
      end
    else
      raise ErrorMessage.new(:remove_access_error.t)
    end
    render :update do |page|
      page.hide dom_id(@gpart || @upart)
    end
  end

  def track_action(event = nil, event_options = nil)
    super participation: participation
  end

  # we always load the user participation for page sidebar controllers
  # so use the group participation if it's present and fallback to user part.
  def participation
    @gpart || @upart
  end

  # we only act upon group participations access. There's no staring or
  # watching group participations.
  def fetch_data
    if params[:group] && params[:access]
      @gpart = GroupParticipation.find(params[:id]) if params[:id]
    end
  end

end

