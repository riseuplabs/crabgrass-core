module Page::ParticipationHelper
  # we need to be careful not to trigger any extra queries with this helper,
  # since this could produce really bad load times.
  def edit_page_access(participation)
    url = page_participation_path @page, participation,
                                  group: participation.group?
    select_id = "access_select_#{participation.id}"
    select_page_access(select_id, participation, remove: true,
                                                 onchange: remote_function(
                                                   url: url,
                                                   method: :put,
                                                   loading: show_spinner(dom_id(participation)),
                                                   with: "'access='+$('#{select_id}').value"
                                                 ))
  end

  # shows a link to remove a user participation (called from _permissions.html.erb)
  def link_to_remove_user_participation(upart)
    if may_remove_participation?(upart)
      link_to_remote(I18n.t(:remove), url: { controller: 'base_page/participation', action: 'destroy', page_id: @page.id, upart_id: upart.id }, loading: show_spinner(dom_id(upart)), complete: hide_spinner(dom_id(upart)) + resize_modal)
    end
  end

  # shows a link to remove a group participation (called from _permissions.html.erb)
  def link_to_remove_group_participation(gpart)
    if may_remove_participation?(gpart)
      link_to_remote(I18n.t(:remove), url: { controller: 'base_page/participation', action: 'destroy', page_id: @page.id, gpart_id: gpart.id }, loading: show_spinner(dom_id(gpart)), complete: hide_spinner(dom_id(gpart)) + resize_modal)
    end
  end

  def participation_pagination_links(parts, params = {})
    # for will_paginate to work, we must pass it params hash instead of a url.
    params.reverse_merge! controller: 'pages/participations', page_id: @page.id, action: 'index', tab: 'participation'
    # We can't use the normal ModalboxAjax LinkRenderer since the
    # participations are displayed in a tab within the modalbox
    pagination_links parts, params: params, renderer: LinkRenderer::Ajax
  end
end
