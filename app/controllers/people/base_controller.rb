class People::BaseController < ApplicationController

  before_filter :fetch_person
  before_filter :authorization_required

  permissions 'people'
  helper 'people/base'

  protected

  def fetch_person
    # person might be preloaded by DispatchController
    @user ||= User.find_by_login(params[:person_id] || params[:id])
    unless current_user.may?(:view, @user)
      # let's make sure this looks like a failing dispatch
      @user = nil
      raise_not_found(:page.t)
    end
  end

  def setup_context
    @context = Context.find(@user)
    super
  end

end

