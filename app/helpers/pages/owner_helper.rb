module Pages::OwnerHelper

  protected
  
  def change_page_owner
    if may_move_page?
      html = render(:partial => 'pages/details/change_owner')
      link_to_modal(:edit.t, :html => html, :title => :page_create_owner.tcap, :icon => 'pencil')
    end
  end

  #
  # returns option tags usable in a select menu to choose a page owner.
  # 
  # There are four types of entries:
  #
  #  (1) groups the user is a (direct or indirect) member of
  #  (2) the user
  #  (3) 'none' if !Conf.ensure_page_owner?
  #  (4) the current owner, even if it doesn't meet one of the other criteria.
  #
  # required options:
  #
  #  :selected     -- the item to make selected (either string or group object)
  #
  def options_for_page_owner(options={})
    options_for_select_group(
      options.merge(
       :include_me => true,
       :include_committees => true,
       :include_none => !Conf.ensure_page_owner?
      )
    )
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
