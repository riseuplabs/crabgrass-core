#
# Abstract super class of all the Me controllers.
#
class Me::BaseController < ApplicationController
  before_action :login_required, :fetch_user

  protected

  def fetch_user
    @user = current_user
  end

  def setup_context
    @context = Context::Me.new(current_user)
    super
  end
end
