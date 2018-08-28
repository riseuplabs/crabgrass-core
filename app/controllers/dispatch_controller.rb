# TODO: I think the dispatchController breaks flash hash. Fix it!
#

class DispatchController < ApplicationController
  # this is *not* an action, but the 'dispatch' method from ActionController::Metal
  # The only change here is that we don't return to_a(), but instead whatever
  # process() returns.
  def dispatch(action, request, _response = ActionDispatch::Response.new)
    @action = action
    @_request = request
    @_env = request.env
    @_env['action_controller.instance'] = self
    flash.keep
    find_controller.dispatch(@action, request, _response = ActionDispatch::Response.new)
  end

  protected

  # create a new instance of a controller, and pass it whatever info regarding
  # current group or user context or page object that we have gathered.

  def new_controller(controller_name)
    modify_params controller: controller_name
    class_name = "#{params[:controller].camelcase}Controller"
    klass = class_name.constantize
    if klass.method_defined? :seed_instance
      klass.seed_instance group: @group, user: @user, page: @page
    else
      klass.new
    end
  end

  # We want the modification to also apply to the newly instantiated controller.
  # So we have to modify the request - not just the Parameters instance.
  def modify_params(options = {})
    request.parameters.merge! options
    @_params = nil
  end

  def modify_action(action)
    modify_params action: action
    @action = action
  end
end
