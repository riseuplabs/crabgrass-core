module Groups::PermissionsHelper

  def publicly_visible_checkbox(list)
    list.checkbox do |cb|
      cb.label I18n.t(:group_publicly_visible, :group => @group.group_type)
      cb.input permission_lock_tag(:view, @keys,
        :success => 'setClassVisibility(".details", $("public_view_check_link").hasClassName("check_on_16"))')
      cb.info I18n.t(:group_publicly_visible_description, :domain => current_site.domain)
    end
  end

  def committee_publicly_visible_checkbox(list)
    return unless Conf.committees and @group.parent_id.nil?
    list.checkbox(:class => 'details', :hide => hidden?) do |cb|
      cb.label I18n.t(:committee_publicly_visible)
      cb.input permission_lock_tag(:see_committees, @keys)
      cb.info I18n.t(:committee_publicly_visible_description, :domain => current_site.domain)
    end
  end

  def networks_publicly_visible_checkbox(list)
    return unless Conf.networks
    list.checkbox(:class => 'details', :hide => hidden?) do |cb|
      cb.label I18n.t(:networks_publicly_visible)
      cb.input permission_lock_tag(:see_networks, @keys)
      cb.info I18n.t(:networks_publicly_visible_description, :domain => current_site.domain)
    end
  end

  def group_members_publicly_visible_checkbox(list)
    list.checkbox(:class => 'details', :hide => hidden?) do |cb|
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
    list.checkbox do |cb|
      cb.label I18n.t(:open_group)
      cb.input check_box(:profile, :membership_policy, {:onclick => ''}, Profile::MEMBERSHIP_POLICY[:open], Profile::MEMBERSHIP_POLICY[:approval])
      cb.info I18n.t(:open_group_description)
    end
  end

  def members_may_edit_wiki_checkbox(list)
    list.checkbox do |cb|
      cb.label I18n.t(:members_may_edit_wiki)
      cb.input check_box(:profile, :members_may_edit_wiki, :onclick => '')
      cb.info I18n.t(:members_may_edit_wiki_description)
    end
  end

  def council_field(row)
    if @group.council_id
      row.input link_to_group(@group.council, :avatar => :small)
    else
#      row.input link_to(I18n.t(:create_a_new_thing, :thing => I18n.t(:council).downcase), councils_url(:action => 'new'))
      row.info I18n.t(:create_a_new_council_caption)
    end
  end

  private

  def hidden?
    !@group.has_access?(:view, :public)
  end

end

