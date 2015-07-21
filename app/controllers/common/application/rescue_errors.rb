#
# Handles exceptions for all crabgrass controllers.
#
# This is an easy way to report an error in crabgrass:
#
#   raise ErrorMessage.new("i am sorry dave, i can't do that right now")
#
# Or, you can use the helper:
#
#   raise_error("i am sorry dave, i can't do that right now")
#
# For not found, use:
#
#   raise_not_found
#
# Or simply use ActiveRecord finders that raise ActiveRecord::RecordNotFound
# It will have the same effect.
#
# Some people might consider this bad programming style, since it uses exceptions
# for error messages and they consider exceptions to be only for the unexpected.
#
# However, raise_error is pretty explicit, and is just an easy way to bail out
# of the current controller and report the error. The problem is, there is a lot
# of common logic to error reporting, and it seems a shame to repeat this everywhere
# you want to display a simple error message.
#
# The use of 'raise ErrorMessage.new' is more like a goto, and could lead to problems.
# In some cases, however, it is nice to put sanity checking deep in the models where
# it would be impractical to expose an api for testing the validity of every object.
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
      rescue_from AuthenticationRequired,      with: :render_authentication_required
      rescue_from PermissionDenied,            with: :render_permission_denied
      rescue_from ActionController::InvalidAuthenticityToken, with: :render_csrf_error

      # Use the ExceptionApp with ExceptionsController for these:
      # ( this is the default for errors that do not inherit from
      #   one of the above)
      rescue_from ErrorNotFound,               with: :raise

      #helper_method :rescues_path
      #alias_method_chain :rescue_action_locally, :js
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
    # If a Proc is specified instead of a symbol, the resulting code is executed.
    #
    #   rescue_render :update => lambda { blah blah }
    #
    def rescue_render(hsh=nil)
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

#  # allows us to set a new path for the rescue templates
#  def rescues_path(template_name)
#    file = "#{Rails.root}/app/views/rescues/#{template_name}.erb"
#    if File.exists?(file)
#      return file
#    else
#      return super(template_name)
#    end
#  end

  #
  # handles suspected "cross-site request forgery" errors
  #
  def render_csrf_error(exception=nil)
    render template: 'account/csrf_error', layout: 'notice'
  end

  #
  # show a permission denied page, or prompt for login
  #
  def render_permission_denied(exception)
    log_exception(exception)
    respond_to do |format|
      format.html do
        render_auth_error_html(exception)
      end
      format.js do
        render_error_js(exception, status: 401)
      end
      format.xml do
        headers["Status"]           = "Unauthorized"
        headers["WWW-Authenticate"] = %(Basic realm="Web Password")
        render text: "Could not authenticate you", status: '401 Unauthorized'
      end
    end
  end

  #
  # show the login screen
  #
  def render_authentication_required(exception)
    render_permission_denied(exception)
  end

  #
  # tries to automatically render the most appropriate thing.
  # for ajax, no problem, we render some rjs.
  # for html, we try to to figure out the best template to render.
  #
  def render_error(exception=nil, options={})
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

  #
  # override the default 'rescue_action_locally' so that we can print an error
  # message when the request is an ajax one.
  #
  # How is this different than 'render_error' with format.js?
  #
#  def rescue_action_locally_with_js(exception)
#    respond_to do |format|
#      format.html do
#        if Rails.env.production? or Rails.env.development?
#          rescue_action_locally_without_js(exception)
#        else
#          render :text => exception
#         end
#      end
#      format.js do
#        add_variables_to_assigns
#        @template.instance_variable_set("@exception", exception)
#        @template.instance_variable_set("@rescues_path", File.dirname(rescues_path("stub")))
#        @template.send!(:assign_variables_from_controller)
#        render :template => 'rescues/diagnostics.rjs', :layout => false
#      end
#    end
#  end

  private

  def render_error_html(exception=nil, options={})
    if exception
      alert_message :error, exception
    end

    if options[:redirect]
      redirect_to options[:redirect]
    end

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
          elsif action.is_a?(Proc)
            self.instance_eval(&action)
          end
        elsif params[:action] == 'update'
          render action: 'edit'
        elsif params[:action] == 'create'
          render action: 'new'
        elsif params[:action]
          render action: params[:action]  # this is generally a bad idea. it probably means
                                             # that a GET request resulted in an error.
        end
      end
    rescue ActionView::MissingTemplate => exc
      # well, we guess poorly.
      render_alert
    end

    # if we ended up redirecting, then ensure that any :now flash is changed to :later
    if @preformed_redirect
      force_later_alert
    end
  end

  def render_auth_error_html(exception)
    alert_message exception, :later
    if logged_in?
      # fyi, this template will eat the alert_message
      render template: 'error/permission_denied', layout: 'notice'
    else
      # request.path does not keep query params. But we need them in some cases.
      after_login = url_for params.merge(only_path: true)
      redirect_to root_path(redirect: after_login)
    end
  end

  def render_error_js(exception=nil, options={})
    error exception if exception.present?
    log_exception(exception)
    return if performed?  # error in after_filter
    render template: 'error/alert', locals: {exception: exception},
      status: options[:status]
  end

  def log_exception(exception)
    Rails.logger.debug "Rescuing from #{exception.class}."
    Rails.logger.debug exception.log_message if exception.respond_to? :log_message
    Rails.logger.debug Rails.backtrace_cleaner.clean(exception.backtrace).join("\n")
  end

  #def flash_auth_error(mode)
  #  if mode == :now
  #    flsh = flash.now
  #  else
  #    flsh = flash
  #  end
  #
  #  if logged_in?
  #    add_flash_message(flsh, :title => I18n.t(:alert_permission_denied), :error => I18n.t(:permission_denied_description))
  #  else
  #    add_flash_message(flsh, :title => I18n.t(:login_required), :type => 'info', :text => I18n.t(:login_required_description))
  #  end
  #end

end

