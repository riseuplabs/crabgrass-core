class Me::NoticesController < Me::BaseController
  before_filter :fetch_notice, only: %i[destroy]

  def index
    @notices = Notice.for_user(current_user)
                     .dismissed(params[:view] == 'old')
                     .includes(:noticable)
                     .order('created_at DESC')
                     .paginate(pagination_params)

    @pages = Page.paginate_by_path '', options_for_me, pagination_params
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

  # we don't really have a post path yet. Partially due to the
  # way they are attached to pages via discussions.
  def post_path(post, *args)
    page_post_path(post.discussion.page, post, *args)
  end
end
