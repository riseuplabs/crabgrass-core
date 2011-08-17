#
# Controllers that include this must define:
#
# request_path(*args) -- returns a path for the args. First arg is a request object.
#

module Common::Requests

  def self.included(base)
    base.class_eval do
      before_filter :fetch_request, :only => [:update, :destroy]

      permissions 'requests'
      guard :update => :may_update_request?, :destroy => :may_destroy_request?

      helper_method :current_state
      helper_method :left_id
      helper_method :right_id
      helper_method :request_path
    end
  end

  #
  # update action changes the state of the request
  #
  def update
    if mark
      @request.mark!(mark, current_user)
      if mark == :approve
        msg = :approved_by_entity.t(:entity => current_user.name)
      elsif mark == :reject
        msg = :rejected_by_entity.t(:entity => current_user.name)
      end
      success I18n.t(@request.name), msg
    end
    render :template => 'common/requests/update'
  end

  #
  # destroy a request
  #
  def destroy
    @request.destroy
    notice :thing_destroyed.tcap(:thing => I18n.t(@request.name))
    render :template => 'common/requests/destroy'
  end

  protected

  def current_state
    case params[:state]
      when 'approved' then :approved;
      when 'rejected' then :rejected;
      else :pending;
    end
  end

  def mark
    case params[:mark]
      when 'reject' then :reject;
      when 'approve' then :approve;
    end
  end

  def left_id(request)
    "panel_left_#{request.dom_id}"
  end

  def right_id(request)
    "panel_right_#{request.dom_id}"
  end

  #
  # this looks dangerous, but is not, because requests
  # have their own permission system.
  #
  def fetch_request
    @request = Request.find(params[:id])
  end

  def request_path(*args)
    raise 'you forgot to override this method'
  end

end

