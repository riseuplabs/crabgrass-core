#          group_members GET    /groups/:group_id/members(.:format)                  {:action=>"index", :controller=>"groups/members"}
#                        POST   /groups/:group_id/members(.:format)                  {:action=>"create", :controller=>"groups/members"}
#       new_group_member GET    /groups/:group_id/members/new(.:format)              {:action=>"new", :controller=>"groups/members"}
#      edit_group_member GET    /groups/:group_id/members/:id/edit(.:format)         {:action=>"edit", :controller=>"groups/members"}
#           group_member GET    /groups/:group_id/members/:id(.:format)              {:action=>"show", :controller=>"groups/members"}
#                        PUT    /groups/:group_id/members/:id(.:format)              {:action=>"update", :controller=>"groups/members"}
#                        DELETE /groups/:group_id/members/:id(.:format)              {:action=>"destroy", :controller=>"groups/members"}


class Groups::MembersController < Groups::BaseController

  def index
  end

end

