#
# Every user to user relationship potentially has a discussion record associated
# with it. This controller is for that discussion.
#
# In this controller, the :id of a discussion is the login name of the other user.
#
# note: the route for this shows up at /me/messages, not /me/discussions
#

class Me::DiscussionsController < Me::BaseController
  # helper 'autocomplete', 'javascript'

  # GET /me/messages
  # we currently lack pagination and filtering for unread
  def index
    @discussions = current_user.discussions.with_some_posts
  end

  # GET /me/messages/penguin
  #def show
  #  @other_user = User.find_by_login(params[:id])
  #  @discussion = current_user.discussions.from_user(@other_user).first
  #  @discussion.mark!(:read, current_user)
  #  @posts = @discussion.posts.paginate(post_pagination_params)
  #rescue Exception => exc
  #  render_error exc
  #end

  # PUT /me/messages/penguin
  #def update
  #  @other_user = User.find_by_login(params[:id])
  #  @discussion = current_user.discussions.from_user(@user_user).first
  #  if params[:state]
  #    @discussion.mark!(params[:state], current_user)
  #  end
  #rescue Exception => exc
  #  render_error exc
  #end

  protected

  def post_pagination_params
    default_page = params[:page].blank? ? @discussion.last_page : nil
    pagination_params(:page => default_page)
  end

end
