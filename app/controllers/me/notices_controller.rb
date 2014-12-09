class Me::NoticesController < Me::BaseController

  before_filter :fetch_notice, only: [:show, :destroy]

  def index
    @notices = Notice.for_user(current_user).
      dismissed(params[:view] == 'old').
      paginate(pagination_params.merge(order: "created_at desc"))
    @pages = current_user.pages.not_deleted.recent_pages
  end

  def show
    url = self.send(@notice.noticable_path, @notice.noticable)
    respond_to do |format|
      format.html { redirect_to url }
      format.js  { render(:update){|page| page.redirect_to url} }
    end
  end

  #
  # don't actually destroy, just mark dismissed
  #
  def destroy
    @notice.dismiss!
  end

  protected

  def fetch_notice
    @notice = Notice.for_user(current_user).find(params[:id])
  end

end
