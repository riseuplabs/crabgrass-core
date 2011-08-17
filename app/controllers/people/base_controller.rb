class People::BaseController < ApplicationController

  before_filter :fetch_person
  permissions 'people'
  helper 'people/base'

  protected

  def fetch_person
    # person might be preloaded by DispatchController
    @user ||= User.find_by_login(params[:person_id] || params[:id])
  end

  def setup_context
    Context.find(@user)
  end

  def pending_friend_request(options)
    from = options[:from]
    to   = options[:to]
    RequestToFriend.created_by(from).to_user(to).having_state('pending').find(:first)
  end
  helper_method :pending_friend_request

end

