class StaticController < ActionController::Base

  def greencloth
    # do not send a session cookie.
    request.session_options[:skip] = true
    render layout: 'static'
  end
end
