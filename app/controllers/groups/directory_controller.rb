class Groups::DirectoryController < ApplicationController
  skip_before_filter :login_required

  stylesheet 'directory'
  helper 'groups/directory'
  permission_helper 'groups/structures'

  def index
    if !logged_in?
      @groups = Group.with_access(:public => :view).groups_and_networks.paginate(pagination_params)
    elsif my_groups?
      @groups = current_user.primary_groups_and_networks.paginate(pagination_params)
    else
      @groups = Group.with_access(current_user => :view).groups_and_networks.paginate(pagination_params)
    end
  end

  protected
  helper_method :my_groups?

  def my_groups?
    params[:path].try.include? 'my'
  end

end

