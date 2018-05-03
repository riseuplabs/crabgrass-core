module Group::PermissionsHelper
  def publicly_visible_checkbox(form)
    form.row do |r|
      r.input castle_gate_tag(@group, :view, @holders, label: :group_publicly_visible.t(group: t(@group.group_type.downcase)))
      r.info :group_publicly_visible_description.t(domain: current_site.domain, group: t(@group.group_type.downcase))
    end
  end

  def committee_publicly_visible_checkbox(form)
    return unless Conf.committees and @group.parent_id.nil?
    form.row(disabled: group_hidden?, class: 'depends_on_view') do |r|
      r.input castle_gate_tag(@group, :see_committees, @holders, label: :committee_publicly_visible.t)
      r.info :committee_publicly_visible_description.t(domain: current_site.domain)
    end
  end

  def networks_publicly_visible_checkbox(form)
    return unless Conf.networks and !@group.council?
    form.row(disabled: group_hidden?, class: 'depends_on_view') do |r|
      r.input castle_gate_tag(@group, :see_networks, @holders, label: :networks_publicly_visible.t)
      r.info :networks_publicly_visible_description.t(domain: current_site.domain)
    end
  end

  def group_members_publicly_visible_checkbox(form)
    form.row(disabled: group_hidden?, class: 'depends_on_view') do |r|
      r.input castle_gate_tag(@group, :see_members, @holders, label: :group_members_publicly_visible.t)
      r.info :group_members_publicly_visible_description.t(domain: current_site.domain, group: t(@group.group_type.downcase))
    end
  end

  def allow_membership_requests_checkbox(form)
    form.row(class: 'depends_on_view') do |r|
      r.input castle_gate_tag(@group, :request_membership, @holders, label: :allow_membership_requests.t)
      r.info :may_request_membership_description.t(group: t(@group.group_type.downcase))
    end
  end

  def open_membership_policy_checkbox(form)
    return if @group.council?
    form.row(class: 'depends_on_request_membership depends_on_view', disabled: group_closed?) do |r|
      r.input castle_gate_tag(@group, :join, @holders, label: :open_group.t(group: t(@group.group_type.downcase)))
      r.info :open_group_description.t(group: t(@group.group_type.downcase))
    end
  end

  def members_may_edit_wiki_checkbox(form)
    form.row do |r|
      r.input castle_gate_tag(@group, :edit, [CastleGates::Holder[@group]], label: :members_may_edit_wiki.t)
      r.info :members_may_edit_wiki_description.t(group: t(@group.group_type.downcase))
    end
  end

  def group_hidden?
    !@group.access?(public: :view)
  end

  def group_closed?
    !@group.access?(public: :request_membership)
  end
end
