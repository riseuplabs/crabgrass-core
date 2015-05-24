#
# ExceptionHandler for ActionDispatch Middleware.
#
# Will use routes to handle 404 and the files in public for 500 and 422
#
module Crabgrass
  class PublicExceptions < ActionDispatch::PublicExceptions

    def call(env)
      render_with_exceptions_controller(env) || super
    end

    def render_with_exceptions_controller(env)
      status = env["PATH_INFO"][1..-1]
      return unless status == '404'
      ExceptionsController.action(:show).call(env)
    rescue Exception => controller_error
      $stderr.puts <<-EOERR
ERROR: ExceptionsController raised:
  #{controller_error}.
  #{controller_error.backtrace * "\n  "}
EOERR
      return false
    end
 
  end
end
