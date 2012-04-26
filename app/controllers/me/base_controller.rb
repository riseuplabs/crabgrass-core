#
# Abstract super class of all the Me controllers.
#
class Me::BaseController < ApplicationController

  before_filter :login_required, :fetch_user
  #stylesheet 'me'
  permissions 'me'

  protected

  def authorized?
    true
  end

  def fetch_user
    @user = current_user
  end

  def setup_context
    @context = Context::Me.new(current_user)
    super
  end

end
