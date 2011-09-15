class Groups::DirectoryController < ApplicationController
  stylesheet 'directory'
  helper 'groups/directory'
  permissions 'groups/affiliations'

  def index
    if !logged_in?
      @groups = Group.access_by(:public).allows(:view).groups_and_networks.paginate(pagination_params)
    elsif my_groups?
      @groups = current_user.primary_groups_and_networks.paginate(pagination_params)
    else
      @groups = Group.access_by(current_user).allows(:view).groups_and_networks.paginate(pagination_params)
    end
  end

  protected
  helper_method :my_groups?

  def my_groups?
    params[:path].try.include? 'my'
  end

end

