#
# links used on group pages
#

module Groups::LinksHelper

  protected

  ##
  ## HOME LINKS
  ##

  def more_info_link
    link_to("More Info", '#')
  end

  def edit_group_profile_link
    if may_admin_group?
      link_to :edit_profile_link.t, edit_group_profile_path(@group)
    end
  end

  ##
  ## MY MEMBERSHIP
  ##

  def join_group_link
    return unless logged_in? and !current_user.direct_member_of? @group
    if may_join_group?
      link_to :join_group_link.t(:group_type => @group.group_type),
        group_my_memberships_path(@group),
        :confirm => :join_group_confirmation.t(:group_type => @group.group_type),
        :method => :post
    elsif may_create_join_request?
      req = RequestToJoinYou.having_state(:pending).find_by_created_by_id_and_recipient_id(current_user.id, @group.id)
      if req
        link_line :bullet, :request_exists.t, link_to(:show_thing.t(:thing => :request.t), me_request_path(req))
      else
        link_to :request_join_group_link.t(:group_type => @group.group_type),
          group_membership_requests_path(@group, :type => 'join'),
          :method => 'post'
      end
    end
  end

  def leave_group_link
    if may_leave_group?
      link_to :leave_group_link.t(:group_type => @group.group_type),
        group_my_membership_path(@group, current_user),
        :confirm => :leave_group_confirmation.t(:group_type => @group.group_type),
        :method => :delete,
        :class => 'navi'
    end
  end

  ##
  ## MEMBERSHIPS
  ##

  def list_memberships_link
    if may_edit_memberships?
      link_to(:edit.t, group_memberships_path(@group))
    elsif may_list_memberships?
      link_to(:see_all_link.t, group_memberships_path(@group))
    end
  end

  def invite_link
    if may_create_group_invite?
      link_to(:send_invites.t, new_group_invite_path(@group))
    end
  end

  def requests_link
    if may_admin_group?
      link_to(:view_requests.t, group_requests_path(@group))
    end
  end

  def destroy_group_link
    if logged_in?
      if RequestToDestroyOurGroup.already_exists?(:group => @group)
        "" # i guess do nothing?
      elsif may_destroy_group?
        link_to_with_confirm(:destroy_thing.t(:thing => @group.group_type),
          {:confirm => :destroy_confirmation.t(:thing => @group.group_type.downcase),
           :url => direct_group_path(@group), :method => :delete }, :class => 'btn')
      elsif may_create_destroy_request?
        link_to(:destroy_thing.t(:thing => @group.group_type),
          group_requests_path(@group, :type => 'destroy_group'),
          :method => 'post', :class => 'btn')
      end
    end
  end

  def create_committee_link
    if may_create_committee?
      link_to :create_button.t, new_group_committee_path(@group)
    end
  end

  def create_council_link
    if logged_in?
      if req = RequestToCreateCouncil.existing(:group => @group)
        link_to(:request_pending.t(:request => :request_to_create_council.t.capitalize), group_request_path(@group, req))
      elsif may_create_council?
        link_to(:create_a_new_thing.t(:thing => :council.t.downcase), new_group_council_path(@group))
      elsif may_create_council_request?
        link_to(:create_a_new_thing.t(:thing => :council.t.downcase),
          group_requests_path(@group, :type => 'create_council'),
          :method => 'post')
      end
    end
  end

  #
  # remove a user from a group or a group from a network.
  #
  def destroy_membership_link(membership)
    if membership.user_id == current_user.id
      leave_group_link
    elsif may_destroy_membership?(membership)
      confirm = :membership_destroy_confirm_message.t(
        :entity => content_tag(:b,membership.entity.name),
        :group => content_tag(:b,@group.name))
      link_to_remote(:remove.t,
        {:url => group_membership_path(@group, membership),
        :method => 'delete',
        :confirm => confirm},
        :icon => 'minus')
    else
      if membership.entity.is_a? Group
        return 'not yet supported'
        req = RequestToRemoveGroup.existing(:group => membership.entity, :network => @group)
      else
        req = RequestToRemoveUser.existing(:user => membership.entity, :group => @group)
      end

      if req
        link_to(:request_pending.t(:request => :request_to_remove_user.t.capitalize), group_membership_request_path(@group, req))
      elsif may_create_expell_request?(membership)
        link_to_remote(:remove.t,
          {:url => group_membership_requests_path(@group, :type => 'destroy', :entity => membership.entity.name),
          :method => 'post'},
          :icon => 'minus')
      end
    end
  end

  ##
  ## AVATARS
  ##

  def edit_avatar_link
    url = @group.avatar ? edit_group_avatar_path(@group, @group.avatar) : new_group_avatar_path(@group)
    link_to_modal(:upload_image_link.tcap, :url => url, :icon => 'picture_edit')
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

