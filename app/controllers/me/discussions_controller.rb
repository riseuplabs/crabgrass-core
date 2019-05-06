#
# Every user to user relationship potentially has a discussion record associated
# with it. This controller is for that discussion.
#
# In this controller, the :id of a discussion is the login name of the other user.
#
# note: the route for this shows up at /me/messages, not /me/discussions
#

class Me::DiscussionsController < Me::BaseController

  # GET /me/messages
  # we currently lack pagination and filtering for unread
  def index
    @posts = Post.private_messages(current_user)
                 .last_in_discussion
                 .visible
                 .order('created_at DESC')
                 .includes(:discussion)
  end

  protected

  def post_pagination_params
    default_page = params[:page].blank? ? @discussion.last_page : nil
    pagination_params(page: default_page)
  end
end
