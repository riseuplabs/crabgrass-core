class Person::BaseController < ApplicationController
  before_filter :fetch_person
  before_filter :authorization_required

  permissions 'people'
  helper 'people/base'

  protected

  def fetch_person
    # person might be preloaded by DispatchController
    @user ||= User.where(login: (params[:person_id] || params[:id])).first!
    raise_not_found unless current_user.may?(:view, @user)
  end

  def setup_context
    @context = Context.find(@user)
    super
  end
end
