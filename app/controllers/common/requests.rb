#
# Controllers that include this must define:
#
# request_path(*args) -- returns a path for the args. First arg is a request object.
#

module Common::Requests

  def self.included(base)
    base.class_eval do

      helper_method :current_state
      helper_method :left_id
      helper_method :right_id
      helper_method :request_path
    end
  end

  protected

  def current_state
    case params[:state]
      when 'approved' then :approved;
      when 'rejected' then :rejected;
      else :pending;
    end
  end

  def left_id(request)
    "panel_left_#{request.dom_id}"
  end

  def right_id(request)
    "panel_right_#{request.dom_id}"
  end

  def request_path(*args)
    raise 'you forgot to override this method'
  end

end

