class ExceptionsController < ApplicationController
  layout 'application'

  def show
    @exception       = env['action_dispatch.exception']
    @former_params   = env["action_dispatch.request.parameters"]
    @status_code     = ActionDispatch::ExceptionWrapper.new(env, @exception).status_code
    @rescue_response = ActionDispatch::ExceptionWrapper.rescue_responses[@exception.class.name]

    Rails.logger.info "#{@status_code} - referrer: #{request.referrer}" if request.referrer

    respond_to do |format|
      format.html {
        render :show, status: @status_code, layout: (!request.xhr? && 'notice')
      }
      format.xml  { render xml: details, root: "error", status: @status_code }
      format.json { render json: {error: details}, status: @status_code }
      format.js   { render_error_js(@exception) }
    end
  end

  protected

  def details
    @details ||= {
      title:       translation(:title),
      description: translation(:description)
    }
  end
  helper_method :details

  def translation(scope)
    options = @exception.respond_to?(:options) ? @exception.options : {}
    scope = [:exception, scope, options[:thing]].compact
    thing = I18n.t(options[:thing], default: '')
    I18n.t @rescue_response, scope: scope, thing: thing, cascade: true
  end
end
