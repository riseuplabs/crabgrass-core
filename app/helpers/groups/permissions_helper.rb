module Groups::PermissionsHelper

  def publicly_visible_checkbox(list)
    list.checkbox do |cb|
      cb.label :group_publicly_visible.t(:group => @group.group_type)
      cb.input permission_lock_tag(:view, @keys)
      cb.info :group_publicly_visible_description.t(
        :domain => current_site.domain,
        :group => @group.group_type.capitalize)
    end
  end

  def committee_publicly_visible_checkbox(list)
    return unless Conf.committees and @group.parent_id.nil?
    list.checkbox(:class => 'depends_on_view', :disabled => group_hidden?) do |cb|
      cb.label :committee_publicly_visible.t
      cb.input permission_lock_tag(:see_committees, @keys)
      cb.info :committee_publicly_visible_description.t(
        :domain => current_site.domain)
    end
  end

  def networks_publicly_visible_checkbox(list)
    return unless Conf.networks and !@group.council?
    list.checkbox(:class => 'depends_on_view', :disabled => group_hidden?) do |cb|
      cb.label :networks_publicly_visible.t
      cb.input permission_lock_tag(:see_networks, @keys)
      cb.info :networks_publicly_visible_description.t(
        :domain => current_site.domain)
    end
  end

  def group_members_publicly_visible_checkbox(list)
    list.checkbox(:class => 'depends_on_view', :disabled => group_hidden?) do |cb|
      cb.label :group_members_publicly_visible.t
      cb.input permission_lock_tag(:see_members, @keys)
      cb.info :group_members_publicly_visible_description.t(
        :domain => current_site.domain,
        :group => @group.group_type.capitalize)
    end
  end

  def allow_membership_requests_checkbox(list)
    list.checkbox do |cb|
      cb.label :allow_membership_requests.t
      cb.input permission_lock_tag(:request_membership, @keys)
      cb.info :may_request_membership_description.t(:group => @group.group_type)
    end
  end

  def open_membership_policy_checkbox(list)
    return if @group.council?
    list.checkbox(:class => 'depends_on_request_membership', :disabled => group_closed?) do |cb|
      cb.label :open_group.t(:group => @group.group_type)
      cb.input permission_lock_tag(:join, @keys)
      cb.info :open_group_description.t(:group => @group.group_type)
    end
  end

  def members_may_edit_wiki_checkbox(list)
    list.checkbox do |cb|
      cb.label :members_may_edit_wiki.t
      cb.input permission_lock_tag(:edit, [@member_key])
      cb.info :members_may_edit_wiki_description.t(:group => @group.group_type)
    end
  end

  def council_field(row)
    if @group.council_id
      row.input link_to_group(@group.council, :avatar => :small)
    else
      row.input link_to(
        :create_a_new_thing.t(:thing => I18n.t(:council).downcase),
        new_group_council_path(@group))
      row.info :council_description_details.t(:group => @group.group_type)
    end
  end

  def group_hidden?
    !@group.has_access?(:view, :public)
  end

  def group_closed?
    !@group.has_access?(:request_membership, :public)
  end

end

