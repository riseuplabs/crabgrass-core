class Me::RequestsController < Me::BaseController

  helper :requests

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
    request = Request.find(params[:id])
    if params[:as]
      mark_as = params[:as].to_sym
      request.mark!(mark_as, current_user)
    end
  end

  def destroy
    @request = Request.find(params[:id])
    notice :thing_destroyed.tcap(:thing => :request.t)
  end

  protected

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

  def left_id(request)
    "panel_left_#{request.dom_id}"
  end
  helper_method :left_id

  def right_id(request)
    "panel_right_#{request.dom_id}"
  end
  helper_method :right_id

end
