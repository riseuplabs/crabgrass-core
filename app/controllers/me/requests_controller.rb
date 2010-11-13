class Me::RequestsController < Me::BaseController

  permissions 'requests'
  prepend_before_filter :fetch_request, :only => [:update, :destroy]

  def index
    @requests = Request.
      having_state(current_state).
      send(current_view, current_user).
      by_updated_at.
      paginate(pagination_params)
  end

  # for now, no detailed view of a request :(
  #def show
  #end
  #def edit
  #end

  def update
    if mark_as(params)
      @request.mark!(mark_as(params), current_user)
      success
    end
  end

  def destroy
    #@request.destroy
    notice :thing_destroyed.tcap(:thing => @request.name.tcap)
  end

  protected

  def fetch_request
    @request = Request.find(params[:id])
  end

  def current_view
    case params[:view]
      when "incoming" then :to_user;
      when "outgoing" then :created_by;
      else :to_or_created_by_user;
    end
  end

  def current_state
    case params[:state]
      when 'approved' then :approved;
      when 'rejected' then :rejected;
      else :pending;
    end
  end

  def mark_as(params)
    case params[:state]
      when 'rejected' then :rejected;
      when 'approved' then :approved;
      when 'pending' then :pending;
    end
  end

  def left_id(request)
    "panel_left_#{request.dom_id}"
  end
  helper_method :left_id

  def right_id(request)
    "panel_right_#{request.dom_id}"
  end
  helper_method :right_id

  # unlike other me controllers, we actually want to check
  # permissions for requests.
  def authorized?
    check_permissions!
  end

end
