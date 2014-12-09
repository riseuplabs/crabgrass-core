class People::DirectoryController < ApplicationController

  before_filter :prepare_path

  guard :allow

  def index
    @query ||= finder.query_term
    @users = finder.find
    @users = @users.paginate(pagination_params)
  end

  protected

  attr_writer :path
  def path
    @path ||= params[:path] || default_path
  end

  def prepare_path
    @query = params[:q] || params[:query]
    if @query.present?
      self.path += '/'       unless path.ends_with? '/'
      self.path += "search/" unless path.ends_with? 'search/'
      self.path += @query.strip
    end
  end

  def finder
    @user_finder ||= UserFinder.new(current_user, path)
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

end

