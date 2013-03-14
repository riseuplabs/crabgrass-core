module Pages::ParticipationHelper

  # we need to be careful not to trigger any extra queries with this helper,
  # since this could produce really bad load times.
  def show_or_edit_page_access(participation)
    url = page_participation_path(@page, participation, :group => participation.is_a?(GroupParticipation))
    select_id = "access_select_#{participation.id}"
    display_access_icon(participation) + '&nbsp;'.html_safe +
    if may_remove_participation?(participation)
      select_page_access(select_id, participation, {
        :remove => true,
        :onchange => remote_function(
          :url => url,
          :method => :put,
          :loading => show_spinner(dom_id(participation)),
          :with => "'access='+$('#{select_id}').value"
        )
      })
    else
      display_access(participation)
    end
  end

  # shows a link to remove a user participation (called from _permissions.html.erb)
  def link_to_remove_user_participation(upart)
    if may_remove_participation?(upart)
      link_to_remote(I18n.t(:remove), :url => {:controller => 'base_page/participation', :action => 'destroy', :page_id => @page.id, :upart_id => upart.id}, :loading => show_spinner(dom_id(upart)), :complete => hide_spinner(dom_id(upart)) + resize_modal)
    end
  end

  # shows a link to remove a group participation (called from _permissions.html.erb)
  def link_to_remove_group_participation(gpart)
    if may_remove_participation?(gpart)
      link_to_remote(I18n.t(:remove), :url => {:controller => 'base_page/participation', :action => 'destroy', :page_id => @page.id, :gpart_id => gpart.id}, :loading => show_spinner(dom_id(gpart)), :complete => hide_spinner(dom_id(gpart)) + resize_modal)
    end
  end

end

