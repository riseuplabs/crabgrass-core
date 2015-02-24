#
# Controllers that include this must define:
#
# request_path(*args) -- returns a path for the args. First arg is a request object.
#
# requests_path(*args) -- used for request index.
#
module Common::Requests

  def self.included(base)
    base.class_eval do
      helper_method :current_state
      helper_method :request_path
      helper_method :requests_path
      before_filter :login_required
      before_filter :fetch_request, only: [:update, :destroy, :show]
    end
  end

  # 
  # show the details of a request
  # 
  # this is needed for the case when a user visits a person or group profile
  # and sees that a request is pending and wants to click on a link for more information.
  # 
  def show
    render template: 'common/requests/show'
  end

  #
  # update action changes the state of the request
  #
  def update
    if mark
      @request.mark!(mark, current_user)
      if mark == :approve
        msg = :approved_by_entity.t(entity: current_user.name)
      elsif mark == :reject
        msg = :rejected_by_entity.t(entity: current_user.name)
      end
      success @request.class.model_name.human, msg
    end
    render template: 'common/requests/update'
  end

  #
  # destroy a request.
  # uses model permissions.
  #
  def destroy
    @request.destroy_by!(current_user)
    notice :thing_destroyed.tcap(thing: @request.class.model_name.human), :later
    render(:update) {|page| page.redirect_to requests_path}
  end

  protected

  def current_state
    case params[:state]
      when 'approved' then :approved;
      when 'rejected' then :rejected;
      else :pending;
    end
  end

  #def left_id(request)
  #  dom_id(request, :panel_left)
  #end

  #def right_id(request)
  #  dom_id(request, :panel_right)
  #end

  def request_path(*args)
    raise 'you forgot to override this method'
  end

  def requests_path(*args)
    raise 'you forgot to override this method'
  end

  #
  # this looks dangerous, but is not, because requests
  # have their own model-based permission system.
  #
  def fetch_request
    @request = Request.find(params[:id])
  end

  def mark
    case params[:mark]
      when 'reject' then :reject;
      when 'approve' then :approve;
    end
  end

end

