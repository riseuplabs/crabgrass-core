#
# Routes:
#
#  create:  page_participations_path  /pages/:page_id/participations
#  update:  page_participation_path   /pages/:page_id/participations/:id
#

# TODO: This should become restful... that would allow making full
# use of pundit.

class Page::ParticipationsController < Page::SidebarsController
  helper 'page/participation', 'page/share'

  before_filter :fetch_data
  track_actions :update

  # this is used for ajax pagination
  def index
    authorize @page
  end

  def update
    authorize @page, :show?
    create_or_update
    respond_to do |format|
      format.html { redirect_to @page }
      format.js
    end
  end

  def create
    authorize @page, :show?
    create_or_update
    respond_to do |format|
      format.html { redirect_to @page }
      format.js { render action: :update }
    end
  end

  protected

  def create_or_update
    if params[:access]
      access
    elsif params[:watch]
      watch
    elsif params[:star]
      star
    end
  end

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
      authorize @page, :admin?
      @part = @page.add(@part.entity, access: params[:access])
      @part.save!
    end
    @page.save!
  end

  ## technically, we should probably not destroy the participations
  ## however, since currently the existance of a participation means
  ## view access, then we need to destory them to remove access.
  def destroy
    authorize @page, :admin?
    if policy(@part).destroy?
      @part.destroy
      entity = @part.entity
    else
      raise ErrorMessage.new(:remove_access_error.t)
    end
  end

  def track_action(_event = nil, _event_options = nil)
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
    @part = if params[:group] && params[:group] != 'false'
              @page.group_participations.find(params[:id])
            else
              @page.user_participations.find(params[:id])
            end
  end
end
