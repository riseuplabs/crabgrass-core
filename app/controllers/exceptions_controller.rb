class ExceptionsController < ApplicationController
  layout 'application'

  def show
    @exception       = env['action_dispatch.exception']
    @former_params   = env['action_dispatch.request.parameters']
    @status_code     = ActionDispatch::ExceptionWrapper.new(env, @exception).status_code
    @rescue_response = ActionDispatch::ExceptionWrapper.rescue_responses[@exception.class.name]

    respond_to do |format|
      format.html do
        render :show, status: @status_code, layout: (!request.xhr? && 'notice')
      end
      format.xml  { render xml: details, root: 'error', status: @status_code }
      format.json { render json: { error: details }, status: @status_code }
      format.js   { render_error_js(@exception, status: @status_code) }
      # let's send the error message out somehow.
      format.all { render json: { error: details }, status: @status_code }
    end
  end

  protected

  def details
    @details ||= {
      title:       translate_exception(:title),
      description: translate_exception(:description)
    }
  end
end
