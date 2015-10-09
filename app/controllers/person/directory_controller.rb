class Person::DirectoryController < ApplicationController
  before_filter :login_required
  # ^^ for now, disable public directories. The old behavior was to require
  #    authentication to browse the directory, so we don't want to change this
  #    unexpectedly without either giving people some warning or adding an
  #    additional level to the permissions.

  before_filter :prepare_path

  guard :allow

  def index
    @query ||= finder.query_term
    @users = finder.find.alphabetic_order.paginate(pagination_params)
  end

  protected

  attr_writer :path
  def path
    # make sure to set the param here so it is respected in navigation
    params[:path] ||= default_path
    @path ||= params[:path]
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

