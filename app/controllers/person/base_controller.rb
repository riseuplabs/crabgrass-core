class Person::BaseController < ApplicationController
  before_action :fetch_person
  before_action :setup_context
  after_action :verify_authorized

  helper 'people/base'

  protected

  def fetch_person
    # person might be preloaded by DispatchController
    @user ||= User.where(login: (params[:person_id] || params[:id])).first
    raise_not_found unless @user && policy(@user).show?
  end

  def setup_context
    @context = Context.find(@user)
    super
  end
end
