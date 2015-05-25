class ExceptionsController < ApplicationController
  layout 'application'

  def show
    @exception       = env['action_dispatch.exception']
    @former_params   = env["action_dispatch.request.parameters"]
    @status_code     = ActionDispatch::ExceptionWrapper.new(env, @exception).status_code
    @rescue_response = ActionDispatch::ExceptionWrapper.rescue_responses[@exception.class.name]

    respond_to do |format|
      format.html { render :show, status: @status_code, layout: !request.xhr? }
      format.xml  { render xml: details, root: "error", status: @status_code }
      format.json { render json: {error: details}, status: @status_code }
      format.js   { render_error_js(@exception) }
    end
  end

  protected

  def details
    @details ||= {
      title:       I18n.t(@rescue_response, scope: "exception.title", cascade: true),
      description: I18n.t(@rescue_response, scope: "exception.description", cascade: true)
    }
  end
  helper_method :details

end
