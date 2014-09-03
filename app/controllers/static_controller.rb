class StaticController < ActionController::Base

  def greencloth
    # do not send a session cookie.
    request.session_options[:skip] = true
  end
end
