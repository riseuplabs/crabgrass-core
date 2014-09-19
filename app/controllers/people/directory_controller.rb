class People::DirectoryController < ApplicationController

  before_filter :set_default_path

  guard :allow

  def index
    @users = finder.find_by_path(params[:path])
    @users = @users.paginate(pagination_params) if @users
  end

  protected

  def set_default_path
    if params[:path].empty?
      params[:path] = default_path
    end
  end

  def finder
    @user_finder ||= UserFinder.new(current_user)
  end

  def default_path
    if !logged_in? || params[:q].present?
      'search/' + params[:q]
    elsif current_user.friends.any?
      'contacts'
    elsif current_user.peers.any?
      'peers'
    else
      'search'
    end
  end

end

