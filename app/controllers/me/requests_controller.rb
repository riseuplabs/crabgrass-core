class Me::RequestsController < Me::BaseController

  include_controllers 'common/requests'
  before_filter :fetch_request, :only => [:update, :destroy]

  def index
    @requests = Request.
      having_state(current_state).
      send(current_view, current_user).
      by_updated_at.
      paginate(pagination_params)
    render :template => 'common/requests/index'
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

  def current_view
    case params[:view]
      when "incoming" then :to_user;
      when "outgoing" then :created_by;
      else :to_or_created_by_user;
    end
  end

  def mark
    case params[:mark]
      when 'reject' then :reject;
      when 'approve' then :approve;
    end
  end

  #
  # this looks dangerous, but is not, because requests
  # have their own permission system.
  #
  def fetch_request
    @request = Request.find(params[:id])
  end

  def request_path(*args)
    me_request_path(*args)
  end

end
