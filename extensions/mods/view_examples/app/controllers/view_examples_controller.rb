class ViewExamplesController < ApplicationController

  #before_render :setup_navigation

  def index
    params[:file] ||= 'index'
    setup_navigation
    if Rails.env.development?
      render file: 'view_examples/' + params[:file], layout: 'application'
    end
  end

  protected

  def setup_navigation
    @local_navigation_content = render_to_string partial: 'view_examples/nav', layout: false
  end

end

