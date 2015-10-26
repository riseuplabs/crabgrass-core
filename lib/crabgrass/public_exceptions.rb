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
      return unless ['401', '403', '404'].include? status
      ExceptionsController.action(:show).call(env)
    rescue Exception => controller_error
      $stderr.puts error_log(controller_error)
      Rails.logger.error error_log(controller_error)
      return false
    end

    private

    def error_log(controller_error)
      return <<-EOERR
ERROR: ExceptionsController raised:
  #{controller_error}.
  #{controller_error.backtrace * "\n  "}
EOERR
    end
  end
end
