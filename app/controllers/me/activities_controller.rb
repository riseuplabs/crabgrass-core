class Me::ActivitiesController < Me::BaseController

  def index
    @activities = Activity.send(current_view, current_user).newest.unique.paginate(pagination_params)
  end

  # REST /me/activities/:id
  def show
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


