#
# group_invites  GET    /groups/:group_id/invites action=>"index"
#                POST   /groups/:group_id/invites action=>"create"
#
# group_invite   PUT    /groups/:group_id/invites/:id action=>"update"
#                DELETE /groups/:group_id/invites/:id action=>"destroy"
#

class Groups::InvitesController < Groups::BaseController

  before_filter :login_required
  permissions :invites #, :requests

  include_controllers 'common/controllers/request'

  #
  # list the invites
  #
  def index
    @requests = Request.invites.
      having_state(current_state).
      send(current_view, @group).
      by_updated_at.
      paginate(pagination_params)
  end

  def new
  end

  #
  # create some new invites
  #
  def create
    users, groups, emails = Page.parse_recipients!(params[:recipients])
    groups = [] unless @group.network?

    reqs = []; mailers = []
    unless users.any? or emails.any? or groups.any?
      raise_error('Recipient required')
    end
    users.each do |user|
      reqs << RequestToJoinUs.create(:created_by => current_user,
        :recipient => user, :requestable => @group)
    end
    groups.each do |group|
      reqs << RequestToJoinOurNetwork.create(:created_by=>current_user,
        :recipient => group, :requestable => @group)
    end

    emails.each do |email|
      req = RequestToJoinUsViaEmail.create(:created_by => current_user,
         :email => email, :requestable => @group, :language => I18n.locale.to_s)
      begin
        Mailer.deliver_request_to_join_us!(req, mailer_options)
        reqs << req
      rescue Exception => exc
        error(:now, exc)
        req.destroy
      end
    end

    if reqs.detect{|req|!req.valid?}
      reqs.each do |req|
        if req.valid?
          success(:now, I18n.t(:invite_sent, :recipient => req.recipient.display_name))
        else
          error(:now, "Invalid request for "+req.recipient.display_name)
        end
      end
    else
      success(:now, I18n.t(:invites_sent, :count => reqs.size.to_s))
      params[:recipients] = ""
    end
    redirect_to :action => :index 
  end

  protected

  def current_view
    case params[:view]
      when "incoming" then :to_group;
      when "outgoing" then :from_group;
      else :regarding_group;
    end
  end

end
