#
# Handles exceptions for all crabgrass controllers.
#
# This is an easy way to report an error in crabgrass:
#
#   raise ErrorMessage, "i am sorry dave, i can't do that right now"
#
# For not found, use:
#
#   raise ErrorNotfound, :page
#
# Or simply use ActiveRecord finders that raise ActiveRecord::RecordNotFound.
# They will have the same effect.
#
# Some people might consider this bad programming style, since it uses
# exceptions for error messages and they consider exceptions to be only for the
# unexpected.
#
# However, raise ErrorMessage is pretty explicit, and is just an easy way to
# bail out of the current controller and report the error. The problem is,
# there is a lot of common logic to error reporting, and it seems a shame to
# repeat this everywhere you want to display a simple error message.
#
# The use of 'raise ErrorMessage' is more like a goto, and could lead to
# problems.  In some cases, however, it is nice to put sanity checking deep in
# the models where it would be impractical to expose an api for testing the
# validity of every object.
#

module Common::Application::RescueErrors
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      class_attribute :rescue_render_map,
                      instance_writer: false, instance_reader: false

      # order of precedence is bottom to top.
      rescue_from ActiveRecord::RecordInvalid, with: :render_error
      rescue_from CrabgrassException,          with: :render_error
      rescue_from GreenClothHeadingError,      with: :render_error
      rescue_from ActionController::InvalidAuthenticityToken, with: :render_csrf_error

      # Use the ExceptionApp with ExceptionsController for these:
      # ( this is the default for errors that do not inherit from
      #   one of the above)
      rescue_from ErrorNotFound,               with: :render_not_found
      rescue_from AuthenticationRequired,      with: :render_exception
      rescue_from PermissionDenied,            with: :raise
      rescue_from Pundit::NotAuthorizedError,  with: :log_and_permission_denied

    end
  end

  module ClassMethods
    #
    # The rescue errors code does automatic rendering of errors:
    #
    #   update -> edit
    #   create -> new
    #   otherwise, render current action
    #
    # You can change this default using 'rescue_render'.
    #
    # This only makes sense for normal html posts: ajax requests just return an
    # error message to the requesting page.
    #
    # example usage:
    #
    #   class RobotController < Common::Application
    #     rescue_render :update => :show
    #   end
    #
    # this will render action :show when there is a caught error exception for :update.
    #
    def rescue_render(hsh = nil)
      if hsh
        # this has to be a copy so the super class is not affected.
        # see http://apidock.com/rails/v4.0.2/Class/class_attribute
        map = rescue_render_map || HashWithIndifferentAccess.new
        self.rescue_render_map = map.merge(hsh)
      else
        rescue_render_map
      end
    end
  end

  protected

  #
  # handles suspected "cross-site request forgery" errors
  #
  def render_csrf_error(_exception = nil)
    render template: 'account/csrf_error', layout: 'notice'
  end

  #
  # tries to automatically render the most appropriate thing.
  # for ajax, no problem, we render some rjs.
  # for html, we try to to figure out the best template to render.
  #
  def render_error(exception = nil, options = {})
    if exception
      #  options[:template] ||= exception.template
      #  options[:redirect] ||= exception.redirect
      #  options[:record] ||= exception.record
      options[:status] ||= status_for_exception(exception)
    end
    respond_to do |format|
      format.html do
        render_error_html(exception, options)
      end
      format.js do
        render_error_js(exception, options)
      end
    end
  end

  #
  # shows a generic not found page or error message, customized
  # by any message in the exception.
  #
  # Please do not call this directly but rather use
  # `raise_not_found :file`
  #
  def render_not_found(exception=nil)
    render_exception exception || ErrorNotFound.new(:page)
  end

  def render_exception(exception)
    @exception = exception
    status = status_for_exception(exception)
    respond_to do |format|
      format.html do
        render 'exceptions/show', status: status, layout: (!request.xhr? && 'notice')
      end
      format.js do
        render_error_js exception, status: status
      end
      format.any do
        render status: status, body: nil
      end
    end
  end

  def log_and_permission_denied(exception)
    Rails.logger.info exception
    Rails.logger.info "User id: #{current_user.id}"
    raise PermissionDenied
  end

  def status_for_exception(exception)
    class_name = exception.class.name
    ActionDispatch::ExceptionWrapper.status_code_for_exception(class_name)
  end

  #
  # used to render the alerts inline as the sole content of the page, useful
  # when you want to report an error but floating errors are no good because you
  # don't want to disclose anything about the page or because you don't have
  # the data required to render the page.
  #
  def render_alert
    render template: 'error/alert', layout: 'notice'
  end

  private

  def render_error_html(exception = nil, options = {})
    alert_message :error, exception if exception

    redirect_to options[:redirect] if options[:redirect]

    #
    # try to guess the best template to use for rendering the error.
    #
    begin
      if !performed? and !@performed_render
        if options[:template]
          render template: options[:template], status: options[:status]
        elsif options[:action]
          render action: options[:action], status: options[:status]
        elsif self.class.rescue_render && self.class.rescue_render[params[:action]]
          action = self.class.rescue_render[params[:action]]
          if action.is_a?(Symbol)
            if action == :alert
              render_alert
            else
              render action: action
            end
          end
        elsif params[:action] == 'update'
          render action: 'edit'
        elsif params[:action] == 'create'
          render action: 'new'
        elsif params[:action]
          render action: params[:action] # this is generally a bad idea. it probably means
          # that a GET request resulted in an error.
        end
      end
    rescue ActionView::MissingTemplate => exc
      # well, we guess poorly.
      render_alert
    end

    # if we ended up redirecting, then ensure that any :now flash is changed to :later
    force_later_alert if @preformed_redirect
  end

  def render_error_js(exception = nil, options = {})
    error exception if exception.present?
    log_exception(exception)
    return if performed? # error in after_action
    render template: 'error/alert', locals: { exception: exception },
           status: options[:status]
  end

  def log_exception(exception)
    Rails.logger.warn "Rescuing from #{exception.class}."
    Rails.logger.warn exception.log_message if exception.respond_to? :log_message
    if exception.backtrace
      Rails.logger.warn Rails.backtrace_cleaner.clean(exception.backtrace).join("\n")
    end
  end

end
