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

  def participation_pagination_links(parts, params = {})
    # for will_paginate to work, we must pass it params hash instead of a url.
    params.reverse_merge! controller: 'participations', page_id: @page.id, action: 'index', tab: 'participation'
    # We can't use the normal ModalboxAjax LinkRenderer since the
    # participations are displayed in a tab within the modalbox
    pagination_links parts, params: params, renderer: LinkRenderer::Ajax
  end
end
