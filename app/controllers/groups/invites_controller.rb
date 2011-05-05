#          group_invites GET    /groups/:group_id/invites(.:format)                  {:action=>"index", :controller=>"groups/invites"}
#                        POST   /groups/:group_id/invites(.:format)                  {:action=>"create", :controller=>"groups/invites"}
#       new_group_invite GET    /groups/:group_id/invites/new(.:format)              {:action=>"new", :controller=>"groups/invites"}
#      edit_group_invite GET    /groups/:group_id/invites/:id/edit(.:format)         {:action=>"edit", :controller=>"groups/invites"}
#           group_invite GET    /groups/:group_id/invites/:id(.:format)              {:action=>"show", :controller=>"groups/invites"}
#                        PUT    /groups/:group_id/invites/:id(.:format)              {:action=>"update", :controller=>"groups/invites"}
#                        DELETE /groups/:group_id/invites/:id(.:format)              {:action=>"destroy", :controller=>"groups/invites"}

# invites are just a type of request, so it might make sense to use
# the requests controller for this...

class Groups::InvitesController < Groups::BaseController
  before_filter :login_required

  permissions :invites

  def index
    scope = case params[:view]
      when 'incoming': :to_group
      when 'outgoing': :from_group
      else :regarding_group
      end
    @requests = Request.send(scope, @group).
      having_state(params[:state]).by_created_at.paginate(pagination_params(:page => params[:out_page]))
    render :template => 'requests/index.html.haml'
  end

  def new
  end

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

end
