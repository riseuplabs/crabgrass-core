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

end
