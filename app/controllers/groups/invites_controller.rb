#
# group_invites  GET    /groups/:group_id/invites action=>"index"
#                POST   /groups/:group_id/invites action=>"create"
#
# update and destroy are handled by Me::RequestsController

class Groups::InvitesController < Groups::BaseController

  before_filter :login_required

  def new
  end

  #
  # create some new invites, possibly of the type:
  #
  # RequestToJoinUs
  # RequestToJoinOurNetwork
  # RequestToJoinUsViaEmail
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
        alert_message req
      end
    else
      success reqs.first, :count => reqs.size
      params[:recipients] = ""
    end
    redirect_to :action => :new
  end

end
