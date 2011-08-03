class Groups::DirectoryController < ApplicationController

  def index
    if !logged_in?
      @groups = Group.access_by(:public).allows(:view).find_all_by_type(nil).paginate(pagination_params) # won't show committees or networks
    elsif my_groups?
      @groups = current_user.primary_groups.paginate(pagination_params) #this just paginates on primary groups. we will still show committees underneath. primary_groups are groups, or committees when we don't belong to the parent group
    else
      @groups = Group.access_by(current_user).allows(:view).find_all_by_type(nil).paginate(pagination_params) # find_all_by_type will exclude committees or networks
    end
  end

  protected
  helper_method :my_groups?

  def my_groups?
    params[:path].try.include? 'my'
  end

end

