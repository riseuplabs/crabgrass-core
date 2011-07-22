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
      link_to_with_confirm(:join_group_link.t(:group_type => @group.group_type), group_joins_path(@group), :confirm => :join_group_confirmation.t(:group_type => @group.group_type), :method => :post)
    elsif may_create_join_request?
      if RequestToJoinYou.having_state(:pending).find_by_created_by_id_and_recipient_id(current_user.id, @group.id)
        :request_exists.t(:request_type => :pending)
      else
        link_to(:request_join_group_link.t(:group_type => @group.group_type), new_group_join_request_path(@group))
      end
    end
  end

  def leave_group_link
    if may_leave_memberships?
      link_to_with_confirm( :leave_group_link.t(:group_type => @group.group_type), group_join_path(@group, current_user),  :confirm => :leave_group_confirmation.t(:group_type => @group.group_type), :method => :delete)
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
    if may_create_committees?
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

  #
  # eventually, this should trigger a request creation.
  # for now, it allows you to immediately remove the user.
  #
  def destroy_membership_link(membership)
    if may_destroy_memberships?(membership)
      link_to_remote :remove.t, :url => group_member_path(@group, membership), :method => 'delete', :confirm => :membership_destroy_confirm_message.t(:user => content_tag(:b,membership.user.name), :group_type => content_tag(:b,@group.name))
      # i think name is more appropriate than group_type, but the keys are already defined with group_type
    end
  end

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

