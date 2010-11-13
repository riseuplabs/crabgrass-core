#
# note: we use the user login for the discussion id.
#

class Me::PostsController < Me::BaseController
  prepend_before_filter :fetch_recipient

  # /me/discussions/green/posts
  def index
    @other_user = User.find_by_login(params[:discussion_id])
    @discussion = current_user.discussions.from_user(@other_user).first
    @discussion.mark!(:read, current_user)
    @posts = @discussion.posts.paginate(post_pagination_params)
  end

  def update
  end

  def create
    in_reply_to = Post.find_by_id(params[:in_reply_to_id])
    current_user.send_message_to!(@recipient, params[:post][:body], in_reply_to)
    respond_to do |wants|
      wants.html { redirect_to me_discussion_posts_url(@recipient.login)}
      wants.js { render :nothing => true }
    end
  end

  protected

  def fetch_recipient
    @recipient = User.find_by_login(params[:discussion_id])
    redirect_to me_discussions_url if @recipient.blank?
  end

  def authorized?
    if current_user == @recipient
      redirect_to me_discussions_url
      error :message_to_self_error.t
    elsif !@recipient.may_be_pestered_by?(current_user)
      redirect_to me_discussions_url
      error :message_cant_pester_error.t(:user => @recipient.name)
    end
    true
  end

  private

  def post_pagination_params
    default_page = params[:page].blank? ? @discussion.last_page : nil
    pagination_params(:page => default_page)
  end

end
