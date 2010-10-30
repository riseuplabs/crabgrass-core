class Me::ActivitiesController < Me::BaseController

  def index
    @activities = Activity.send(current_view, current_user).newest.unique.paginate(pagination_params)
  end

  # GET /me/activities/:id
  def show
  end

  # POST /me/activities
  def create
     #
     # TODO: add permissions to status updates
     #
     @post = StatusPost.create! do |post|
      post.body = params[:post][:body]
      post.discussion = current_user.wall_discussion
      post.user = current_user
      post.recipient = current_user
      post.body_html = post.lite_html
    end
    redirect_to me_activities_url
  end

  protected

  def current_view
    case params[:view]
      when 'friends' then 'for_my_friends';
      when 'groups' then 'for_my_groups';
      when 'my' then 'for_me';
      else 'for_all';
    end
  end

end


