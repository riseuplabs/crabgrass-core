class Groups::DirectoryController < ApplicationController

  def index
    if !logged_in?
      @groups = Group.access_by(:public).allows(:view).paginate(pagination_params)
    else
      @groups = Group.access_by(current_user).allows(:view).paginate(pagination_params)
    end
  end

end

