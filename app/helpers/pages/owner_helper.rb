module Pages::OwnerHelper

  protected
  
  def change_page_owner
    if may_move_page?
      html = render(:partial => 'pages/details/change_owner')
      link_to_modal(:edit.t, :html => html, :title => :page_create_owner.tcap, :icon => 'pencil')
    end
  end

=begin
  def select_page_owner
    if may_move_page?
      content_tag(:form,
        select_tag('owner_name',
          options_for_page_owner(:include_me => true, :selected => @page.owner_name),
          :onchange => 'this.form.submit();'
        ) + hidden_field_tag('authenticity_token', form_authenticity_token),
        :action => url_for(:controller => '/base_page/participation', :action => 'set_owner', :page_id => @page.id),
        :method => 'post'
      )
    elsif @page.owner
      h(@page.owner.both_names)
    else
      I18n.t(:none)
    end
  end
=end

end
