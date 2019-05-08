class Page::PostsController < ApplicationController
  include Common::Tracking::Action

  include_controllers 'common/posts'

  helper 'page/post'

  prepend_before_filter :fetch_data
  before_filter :login_required, except: :show
  after_action :verify_authorized

  track_actions :create, :update, :destroy

  def show
    authorize @page
    respond_to do |format|
      format.js   { render 'common/posts/show' }
      format.html { redirect_to page_url(@page) + "#post-#{@post.id}" }
    end
  end

  def create
    authorize @page, :show?
    if @post = @page.add_post(current_user, post_params)
      respond_to do |format|
        format.js   { @posts = @page.posts(pagination_params) }
        format.html { redirect_to page_url(@page) + "#post-#{@post.id}" }
      end
      authorize @post
    end
  end

  protected

  def fetch_data
    @page = Page.find(params[:page_id])
    if params[:id]
      @post = @page.discussion.posts.includes(:discussion).find(params[:id])
      raise PermissionDenied.new unless @post
    end
  end

  def post_params
    params.require(:post).permit(:body)
  end

  def track_action
    super item: @post
  end
end
