#
# note: we use the user login for the discussion id.
#

class Me::PostsController < Me::BaseController
  include_controllers 'common/posts'

  prepend_before_filter :fetch_data
  after_action :verify_authorized

  # /me/discussions/green/posts
  def index
    skip_authorization
    @other_user = @recipient
    if @discussion
      @discussion.mark!(:read, current_user)
      @posts = @discussion.posts.includes(:user).paginate(post_pagination_params)
    else
      @posts = []
    end
    @post = Post.new
  end

  # used in redirects after editing a post
  def show
    skip_authorization
    respond_to do |format|
      format.js { render 'common/posts/show' }
    end
  end

  def create
    @message = Message.new message_params
    authorize @message
    @message.save
    redirect_to action: :index
  end

  protected

  def message_params
    params.require(:post).permit(:body).merge sender: current_user,
      recipient: @recipient,
      in_reply_to_id: params[:in_reply_to_id]
  end

  def fetch_data
    if params[:discussion_id]
      @recipient = User.find_by_login(params[:discussion_id])
      @discussion = current_user.discussions.from_user(@recipient).first
    end
    if @recipient.blank?
      error(:thing_not_found.t(thing: :recipient.t), :later)
      redirect_to me_discussions_url
    end
    @post = @discussion.posts.find(params[:id]) if params[:id] && @discussion
  end

  private

  def post_pagination_params
    default_page = params[:page].blank? ? @discussion.last_page : params[:page]
    pagination_params(page: default_page)
  end

  #
  # Define the path for editing posts. This is used by the post templates.
  #

  def edit_post_path(post, *args)
    edit_me_discussion_post_path(@recipient, post, *args)
  end
  helper_method :edit_post_path

  def post_path(post, *args)
    me_discussion_post_path(@recipient, post, *args)
  end
  helper_method :post_path

  def posts_path(*args)
    me_discussion_posts_path(@recipient, *args)
  end
  helper_method :posts_path
end
