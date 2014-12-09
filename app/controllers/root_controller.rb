class RootController < ApplicationController

  layout 'notice'

  def index
    redirect_to me_home_path if logged_in?
  end

end
