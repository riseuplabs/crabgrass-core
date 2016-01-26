require 'test_helper'

class ActionController::TestCase

  protected

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
