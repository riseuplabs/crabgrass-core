#
# Routes:
#
#  update:  page_attributes_path      /pages/:page_id/attributes
#

class Page::AttributesController < Page::SidebarsController
  before_filter :login_required
  track_actions :update

  def update
    authorize @page, :admin?
    if params[:public]
      @page.public = params[:public]
      @page.updated_by = current_user
      @page.save!
      respond_to do |format|
        format.html { redirect_to @page }
        format.js { render action: :update }
      end
    elsif owner
      @page.owner = owner
      @page.save!
      redirect_to page_path(@page)
      success
    end
  end

  protected

  def track_action
    super 'update_page'
  end

  def owner
    return unless params[:owner]
    if params[:owner] == current_user.name
      current_user
    else
      Group.where(name: params[:owner]).first!
    end
  end
end
