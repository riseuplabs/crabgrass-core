module Groups::PermissionsHelper

  def publicly_visible_checkbox(list)
    list.checkbox do |cb|
      cb.label I18n.t(:group_publicly_visible, :group => @group.group_type)
      cb.input permission_lock_tag(:view, @keys)
      cb.info I18n.t(:group_publicly_visible_description, :domain => current_site.domain)
    end
  end

  def committee_publicly_visible_checkbox(list)
    return unless Conf.committees and @group.parent_id.nil?
    list.checkbox(:class => 'depends_on_view', :hide => group_hidden?) do |cb|
      cb.label I18n.t(:committee_publicly_visible)
      cb.input permission_lock_tag(:see_committees, @keys)
      cb.info I18n.t(:committee_publicly_visible_description, :domain => current_site.domain)
    end
  end

  def networks_publicly_visible_checkbox(list)
    return unless Conf.networks and !@group.council?
    list.checkbox(:class => 'depends_on_view', :hide => group_hidden?) do |cb|
      cb.label I18n.t(:networks_publicly_visible)
      cb.input permission_lock_tag(:see_networks, @keys)
      cb.info I18n.t(:networks_publicly_visible_description, :domain => current_site.domain)
    end
  end

  def group_members_publicly_visible_checkbox(list)
    list.checkbox(:class => 'depends_on_view', :hide => group_hidden?) do |cb|
      cb.label I18n.t(:group_members_publicly_visible)
      cb.input permission_lock_tag(:see_members, @keys)
      cb.info I18n.t(:group_members_publicly_visible_description, :domain => current_site.domain)
    end
  end

  def allow_membership_requests_checkbox(list)
    list.checkbox do |cb|
      cb.label I18n.t(:allow_membership_requests)
      cb.input permission_lock_tag(:request_membership, @keys)
      cb.info I18n.t(:may_request_membership_description)
    end
  end

  def open_membership_policy_checkbox(list)
    return if @group.council?
    list.checkbox do |cb|
      cb.label I18n.t(:open_group)
      cb.input permission_lock_tag(:join, @keys)
      cb.info I18n.t(:open_group_description)
    end
  end

  def members_may_edit_wiki_checkbox(list)
    list.checkbox do |cb|
      cb.label I18n.t(:members_may_edit_wiki)
      cb.input permission_lock_tag(:edit, [@member_key])
      cb.info I18n.t(:members_may_edit_wiki_description)
    end
  end

  def council_field(row)
    if @group.council_id
      row.input link_to_group(@group.council, :avatar => :small)
    else
      row.input link_to(I18n.t(:create_a_new_thing, :thing => I18n.t(:council).downcase), new_group_council_path(@group))
      row.info :council_description_details.t
    end
  end

  def group_hidden?
    !@group.has_access?(:view, :public)
  end

end

