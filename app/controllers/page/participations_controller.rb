#
# Routes:
#
#  create:  page_participations_path  /pages/:page_id/participations
#  update:  page_participation_path   /pages/:page_id/participations/:id
#

class Page::ParticipationsController < Page::SidebarsController

  guard :may_show_page?, actions: [:update, :create]
  helper 'page/participation', 'page/share'

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
    render action: :update
  end

  protected

  def watch
    @upart = @page.add(current_user, watch: params[:watch])
    @upart.save!
  end

  def star
    @upart = @page.add(current_user, star: params[:star])
    @upart.save!
  end

  def access
    if params[:access] == 'remove'
      destroy
    else
      @part = @page.add(@part.entity, access: params[:access])
      @part.save!
    end
  end

  ## technically, we should probably not destroy the participations
  ## however, since currently the existance of a participation means
  ## view access, then we need to destory them to remove access.
  def destroy
    if may_remove_participation?(@part)
      @part.destroy
      entity = @part.entity
      entity.clear_access_cache if entity.respond_to? :clear_access_cache
    else
      raise ErrorMessage.new(:remove_access_error.t)
    end
  end

  def track_action(event = nil, event_options = nil)
    super participation: participation
  end

  # we always load the user participation for page sidebar controllers
  # so use the participation loaded in fetch_data and fallback to user part.
  def participation
    @part || @upart
  end

  # we only act upon group participations access. There's no staring or
  # watching group participations.
  def fetch_data
    return unless params[:access] && params[:id]
    if params[:group] && params[:group]!= 'false'
      @part = @page.group_participations.find(params[:id])
    else
      @part = @page.user_participations.find(params[:id])
    end
  end

end

