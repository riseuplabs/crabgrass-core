#
# Controllers that include this must define:
#
# request_path(*args) -- returns a path for the args. First arg is a request object.
#
# requests_path(*args) -- used for request index.
#
module Common::Requests
  extend ActiveSupport::Concern

  included do
    helper_method :current_state
    helper_method :request_path
    helper_method :requests_path
    before_filter :fetch_request, only: %i[update destroy show]

    after_filter :create_notices, only: :create
    after_filter :dismiss_notices, only: :update
  end

  #
  # show the details of a request
  #
  # this is needed for the case when a user visits a person or group profile
  # and sees that a request is pending and wants to click on a link for more information.
  #
  def show
    # Finder is limited to requests we can see.
    skip_authorization
    render template: 'common/requests/show'
  end

  #
  # update action changes the state of the request
  #
  def update
    # uses model permissions.
    skip_authorization
    if mark
      @req.mark!(mark, current_user)
      success I18n.t(@req.name), success_message
    end
    render template: 'common/requests/update'
  end

  #
  # destroy a request.
  #
  def destroy
    # uses model permissions.
    skip_authorization
    @req.destroy_by!(current_user)
    notice request_destroyed_message, :later
    render template: 'common/requests/destroy'
  end

  protected

  def current_state
    case params[:state]
    when 'approved' then :approved
    when 'rejected' then :rejected
    else :pending
    end
  end

  def request_destroyed_message
    :thing_destroyed.tcap thing: I18n.t(@req.name, count: 1)
  end

  def request_path(*_args)
    raise 'you forgot to override this method'
  end

  def requests_path(*_args)
    raise 'you forgot to override this method'
  end

  def fetch_request
    @req = request_context.find(params[:id])
    if params[:code] && @req.recipient != current_user
      @req.try.redeem_code!(current_user)
    end
  end

  def request_context
    if params[:code]
      Request.where(code: params[:code])
    else
      Request.visible_to(current_user)
    end
  end

  def mark
    case params[:mark]
    when 'reject' then :reject
    when 'approve' then :approve
    end
  end

  def success_message
    if approved?
      msg = :approved_by_entity.t(entity: current_user.name)
    elsif mark == :reject
      msg = :rejected_by_entity.t(entity: current_user.name)
    end
  end

  def create_notices
    Notice::RequestNotice.create! @req if @req.persisted?
  end

  def dismiss_notices
    Notice::RequestNotice.for_noticable(@req).dismiss_all unless @req.pending?
  end

  def approved?
    mark == :approve
  end
end
