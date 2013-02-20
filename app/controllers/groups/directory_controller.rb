class Groups::DirectoryController < ApplicationController
  skip_before_filter :login_required

  stylesheet 'directory'
  helper 'groups/directory'
  permission_helper 'groups/structures'

  def index
    @groups = groups_to_display.alphabetized(nil).paginate(pagination_params)
  end

  protected
  helper_method :my_groups?

  def my_groups?
    params[:path].try(:include?, 'my')
  end

  def groups_to_display
    if !logged_in?
      Group.with_access(:public => :view).groups_and_networks
    elsif my_groups?
      current_user.primary_groups_and_networks
    else
      Group.with_access(current_user => :view).groups_and_networks
    end
  end
end

