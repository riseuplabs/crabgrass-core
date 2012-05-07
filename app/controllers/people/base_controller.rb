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
    @context = Context.find(@user)
    super
  end

end

