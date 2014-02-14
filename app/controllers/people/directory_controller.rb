class People::DirectoryController < ApplicationController

  skip_before_filter :login_required
  before_filter :set_default_path
  stylesheet 'directory'

  def index
    @users = users_to_display
    @users = @users.order(:login).paginate(pagination_params) if @users
  end

  protected

  def set_default_path
    if params[:path].empty?
      params[:path] = default_path
    end
  end

  def default_path
    if !logged_in?
      'search'
    elsif current_user.friends.any?
      'contacts'
    elsif current_user.peers.any?
      'peers'
    else
      'search'
    end
  end

#  VIEW_KEYWORDS = ['friends', 'peers']

  def users_to_display
    if !logged_in?
      User.with_access(:public => :view)
    elsif friends?
      current_user.friends
    elsif peers?
      current_user.peers
    else
      if filter
        User.named_like(filter).with_access(current_user => :view)
      end
    end
  end

  def friends?
    params[:path].try(:include?, 'contacts')
  end

  def peers?
    params[:path].try(:include?, 'peers')
  end

  def filter
    if q = params[:q]
      q.gsub('%', '\%').gsub('_', '\_') + '%'
    end
  end
end

