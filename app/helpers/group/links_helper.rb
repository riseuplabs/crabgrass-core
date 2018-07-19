#
# links used on group pages
#

module Group::LinksHelper
  protected

  ##
  ## HOME LINKS
  ##

  def more_info_link
    link_to('More Info', '#')
  end

  def edit_group_profile_link
    if may_admin?(@group)
      link_to :edit_profile_link.t, edit_group_profile_path(@group)
    end
  end

  ##
  ## MY MEMBERSHIP
  ##

  def join_group_link
    return unless logged_in?
    return if @membership.persisted?
    if may_create? @membership
      directly_join_group_link
    elsif policy(@group).may_create_join_request?
      join_request_link
    end
  end

  def leave_group_link
    link_to :leave_group_link.t(group_type: t(@group.group_type.downcase)),
            group_my_membership_path(@group, current_user),
            confirm: :leave_group_confirmation.t(group_type: t(@group.group_type.downcase)),
            method: :delete,
            class: 'navi'
  end

  def directly_join_group_link
    link_to :join_group_link.t(group_type: t(@group.group_type.downcase)),
            group_my_memberships_path(@group),
            confirm: :join_group_confirmation.t(group_type: t(@group.group_type.downcase)),
            method: :post
  end

  def join_request_link
    invited = RequestToJoinUs.pending.from_group(@group).to_user(current_user).first
    requested = RequestToJoinYou.pending.created_by(current_user).to_group(@group).first
    if invited
      link_line :bullet, :you_are_invited.t, link_to(:show_thing.t(thing: :request.t), me_request_path(invited))
    elsif requested
      link_line :bullet, :request_exists.t, link_to(:show_thing.t(thing: :request.t), me_request_path(requested))
    else
      link_to :request_join_group_link.t(group_type: t(@group.group_type.downcase)),
              group_membership_requests_path(@group, type: 'join'),
              method: 'post'
    end
  end

  ##
  ## MEMBERSHIPS
  ##

  def list_memberships_link
    if policy(@group).may_list_memberships?
      link_to(:see_all_link.t, group_memberships_path(@group))
    end
  end

  def invite_link
    link_to(:send_invites.t, new_group_invite_path(@group)) if may_admin?(@group)
  end

  def requests_link
    link_to(:view_requests.t, group_requests_path(@group)) if may_admin?(@group)
  end

  def destroy_group_link
    if logged_in?
      if RequestToDestroyOurGroup.already_exists?(group: @group)
        '' # i guess do nothing?
      elsif may_destroy?(@group)
        link_to :destroy_thing.t(thing: @group.display_name),
                  direct_group_path(@group),
                  method: :delete,
                  class: 'btn btn-danger',
                  confirm: :destroy_confirmation.t(thing: @group.name)
      elsif may_create?(request_to_destroy_group)
        link_to :destroy_thing.t(thing: @group.display_name),
                group_requests_path(@group, type: 'destroy_group'),
                method: 'post',
                class: 'btn btn-danger'
      end
    end
  end

  def request_to_destroy_group
    RequestToDestroyOurGroup.new(recipient: @group, requestable: @group)
  end

  def create_committee_link
    if policy(@group).may_create_committee?
      link_to :create_button.t, new_group_committee_path(@group)
    end
  end

  def create_council_link
    if logged_in?
      if req = RequestToCreateCouncil.existing(group: @group)
        link_to(:request_pending.t(request: :request_to_create_council.t.capitalize), group_request_path(@group, req))
      elsif policy(@group).may_create_council?
        link_to(:create_a_new_thing.t(thing: :council.t), new_group_council_path(@group))
      elsif may_create?(request_to_create_council)
        link_to(:create_a_new_thing.t(thing: :council.t),
                group_requests_path(@group, type: 'create_council'),
                method: 'post')
      end
    end
  end

  def request_to_create_council
    RequestToCreateCouncil.new(recipient: @group, requestable: @group)
  end

  #
  # remove a user from a group or a group from a network.
  #
  def destroy_membership_link(membership)
    if may_destroy?(membership)
      if membership.user == current_user
        leave_group_link
      else
        confirm = :membership_destroy_confirm_message.t(
          entity: membership.entity.name,
          group: @group.name
        )
        link_to(:remove.t, group_membership_path(@group, membership),
                remote: true,
                method: 'delete',
                icon: 'minus', data: {confirm: confirm })
      end
    else
      request = expell_request(membership)
      if request.persisted? && !request.approved?
        link_to :request_pending.t(request: request.class.model_name.human),
                group_membership_request_path(@group, request)
      elsif may_create? request
        link_to(:remove.t, group_membership_requests_path(@group, type: 'destroy', entity: membership.entity.name),
               remote: true,
               method: 'post',
               icon: 'minus')
      end
    end
  end

  def expell_request(membership)
    klass = membership.entity.is_a?(Group) ?
      RequestToRemoveGroup :
      RequestToRemoveUser
    klass.for_membership(membership).first_or_initialize
  end

  ##
  ## AVATARS
  ##

  def edit_avatar_link
    url = @group.avatar ? edit_group_avatar_path(@group, @group.avatar) : new_group_avatar_path(@group)
    link_to_modal :upload_image.t, url, icon: 'picture_edit'
  end

  ##
  ## TAGGING
  ##

  def link_to_group_tag(tag, options)
    options[:class] ||= ''
    path = (params[:path] || []).dup
    name = tag.name.tr(' ', '+')
    if path.delete(name)
      options[:class] += ' invert'
    else
      path << name
    end
    options[:title] = tag.name
    link_to tag.name, groups_url(action: 'tags') + '/' + path.join('/'), options
  end
end
