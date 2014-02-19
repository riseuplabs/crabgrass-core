require_relative '../test_helper'

class ActionController::TestCase

  protected

  def run_before_filters(action=nil, params = {})
    @controller.stubs(:action_name).returns(action.to_s) if action
    params.reverse_merge! :action => action,
      :controller => @controller.class.controller_path
    @controller.stubs(:params).returns(params)
    session = ActionController::TestSession.new
    @controller.stubs(:session).returns(session)
    @request.stubs(:session).returns(session)
    @controller.send(:run_callbacks, :process_action, action)
  end

  # get assigns without going through the whole request
  def assigned(name)
    @controller.instance_variable_get("@#{name}")
  end

  # this should give us access to Flash.now flashes
  def flashed
    @controller.send(:flash)[:messages]
  end

  def flashed_errors
    @controller.send(:flash)[:messages].detect {|m| m[:type] == :error or m[:type] == :warning}
  end
end
