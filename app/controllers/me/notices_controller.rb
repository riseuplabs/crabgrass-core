class Me::NoticesController < Me::BaseController

  before_filter :fetch_notice, only: [:show, :destroy]

  def index
    @notices = Notice.for_user(current_user).
      dismissed(params[:view] == 'old').
      paginate(pagination_params.merge(order: "created_at desc"))
    @pages = current_user.pages.not_deleted.order('pages.updated_at desc').limit(30)
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

  def destroy_all
    notices = Notice.for_user(current_user).dismissed(false).each &:dismiss!

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  protected

  def fetch_notice
    @notice = Notice.for_user(current_user).find(params[:id])
  end

end
