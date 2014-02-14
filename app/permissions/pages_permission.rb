module PagesPermission

  protected

  ##
  ## BASIC
  ##

  def may_show_page?(page = @page)
    # public pages are dealt with in login_or_public_page_required
    # in the controller, so we don't need to test for that here.
    !page or current_user.may?(:view, page)
  end

  def may_edit_page?(page = @page)
    current_user.may?(:edit, page)
  end

  def may_admin_page?(page = @page)
    current_user.may?(:admin, @page)
  end

  def may_new_page?
    logged_in?
  end

  def may_create_page?(page = @page)
    !page or may_admin_page?
  end

  alias_method :may_destroy_page?, :may_admin_page?
  alias_method :may_delete_page?, :may_edit_page?

  ##
  ## SHARING
  ##

  # TODO: separate sharing from notifications in the controller
  def may_share_page?(page = @page)
    params ||= {}
    if params[:mode] == 'share'
      may_admin_page?(page)
    else
      may_edit_page?(page)
    end
  end

  ##
  ## PARTICIPATION
  ##

  # if true, then you can choose access permissions when sharing pages. this is
  # used by cc.net. Not sure if this is a hack or a useful general feature.
  def may_select_access_participation?(page=@page)
    page.nil? or current_user.may? :admin, page
  end

  # this does not really test permissions, rather, it lets us know if something
  # horrible would happen if we removed this participation.
  # may_admin_page_without is an expensive call, so this should be used
  # sparingly. this method helps prevent removing yourself from page access,
  # although it is clumsy.
  def may_remove_participation?(part)
    if part.is_a?(UserParticipation)
      if part.user_id != current_user.id
        true
      elsif part.user_id == @page.owner_id and @page.owner_type == 'User'
        false
      else
        current_user.may_admin_page_without?(@page, part)
      end
    elsif part.is_a?(GroupParticipation)
      if !current_user.member_of?(part.group)
        true
      elsif part.group_id == @page.owner_id and @page.owner_type == 'Group'
        false
      else
        current_user.may_admin_page_without?(@page, part)
      end
    else
      false
    end
  end

end

