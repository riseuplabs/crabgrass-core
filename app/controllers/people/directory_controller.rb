class People::DirectoryController < ApplicationController

  skip_before_filter :login_required
  stylesheet 'directory'

  def index
    @users = users_to_display.order(:login).paginate(pagination_params)
  end

  protected

#  VIEW_KEYWORDS = ['friends', 'peers']

  def users_to_display
    if !logged_in?
      User.with_access(:public => :view)
    elsif friends?
      current_user.friends
    elsif peers?
      current_user.peers
    else
      User.with_access(current_user => :view)
    end
  end

  def friends?
    params[:path].try(:include?, 'contacts')
  end

  def peers?
    params[:path].try(:include?, 'peers')
  end

end

