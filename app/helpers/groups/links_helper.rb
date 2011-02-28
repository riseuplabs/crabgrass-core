#
# links used on group pages
#

module Groups::LinksHelper

  protected

  ##
  ## HOME LINKS
  ##

  def join_group_link
    return unless logged_in? and !current_user.direct_member_of? @group
    if may_join_memberships?
      link_to(:join_group_link.t(:group_type => @group.group_type), '#')
    elsif may_create_join_request?
      link_to(:request_join_group_link.t(:group_type => @group.group_type), '#')
    end
  end

  def leave_group_link
    if may_leave_memberships?
      link_to( :leave_group_link.t(:group_type => @group.group_type), '#')
    end
  end

  def more_info_link
    link_to("More Info", '#')
  end

  # members

  def list_membership_link
    if may_edit_memberships?
      link_to(:edit.t, group_members_path(@group))
    elsif may_list_memberships?
      link_to(:see_all_link.t, group_members_path(@group))
    end
  end

  def list_group_membership_link
    if may_list_memberships?
      link_to :see_all_link.t, group_members_path(@group, :view => 'groups')
    end
  end


  def invite_link
    if may_create_invite_request?
      link_to(:send_invites.t, new_group_invite_path(@group))
    end
  end

  def requests_link
    if may_create_invite_request?
      link_to(:view_requests.t, group_requests_path(@group))
    end
  end

  #def destroy_group_link
  #  # eventually, this should fire a request to destroy.
  #  if may_destroy_group?
  #    link_to_with_confirm("Destroy {group_type}"[:destroy_group_link, @group.group_type], {:confirm => "Are you sure you want to delete this {thing}? This action cannot be undone."[:destroy_confirmation, @group.group_type.downcase], :url => groups_url(:action => :destroy), :method => :post})
  #  end
  #end

  #def more_committees_link
  #  ## link_to_iff may_view_committee?, 'view all'[:view_all], ''
  #end

  def create_committee_link
    if may_create_subcommittees?
      link_to :create_button.t, new_group_committee_path(@group)
    end
  end

  #def edit_featured_link(label=nil)
  #  label ||= "edit featured content"[:edit_featured_content].titlecase
  #  if may_edit_featured_pages?
  #    link_to label, groups_features_url(:action => :index)
  #  end
  #end

  #def edit_group_custom_appearance_link(appearance)
  #  if appearance and may_edit_appearance?
  #    link_to "edit custom appearance"[:edit_custom_appearance], edit_custom_appearance_url(appearance)
  #  end
  #end


  ## membership navigation

  #def list_membership_link
  #  link_to_active_if_may('Edit'[:edit], '/groups/memberships', 'edit', @group) or
  #  link_to_active_if_may("See All"[:see_all_link], '/groups/memberships', 'list', @group)
  #end

  #def membership_count_link
  #  link_if_may("{count} members"[:group_membership_count, {:count=>(@group.users.size).to_s}] + ARROW,
  #                 '/groups/memberships', 'list', @group) or
  #  "{count} members"[:group_membership_count, {:count=>(@group.users.size).to_s}]
  #end


  #def group_membership_link
  #  link_to_active_if_may "See All"[:see_all_link], '/groups/memberships', 'groups', @group
  #end

  ##
  ## CREATION
  ##

  def create_group_link
    if @active_tab == :groups
      if may_create_group?
        link_to_with_icon('plus', "Create a new {thing}"[:create_a_new_thing, :group.t.downcase], groups_url(:action => 'new'))
      end
    elsif @active_tab == :networks
      if may_create_network?
        link_to_with_icon('plus', "Create a new {thing}"[:create_a_new_thing, :network.t.downcase], networks_url(:action => 'new'))
      end
    end
  end

  ##
  ## TAGGING
  ##

  def link_to_group_tag(tag,options)
    options[:class] ||= ""
    path = (params[:path]||[]).dup
    name = tag.name.gsub(' ','+')
    if path.delete(name)
      options[:class] += ' invert'
    else
      path << name
    end
    options[:title] = tag.name
    link_to tag.name, groups_url(:action => 'tags') + '/' + path.join('/'), options
  end

end

