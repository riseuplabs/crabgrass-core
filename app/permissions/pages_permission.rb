module PagesPermission

  protected

  ##
  ## CRUD
  ##

  def may_show_page?(page = @page)
    # public pages are dealt with in login_or_public_page_required
    # in the controller, so we don't need to test for that here.
    !page or current_user.may?(:view, page)
  end

  def may_edit_page?(page = @page)
    current_user.may?(:edit, page)
  end

  def may_update_page?
    true
  end

  def may_new_page?
    logged_in?
  end

  def may_create_page?(page = @page)
    !page or may_admin_page?
  end

  def may_destroy_page?
    may_admin_page?
  end

  def may_index_pages?
    logged_in?
  end

  ##
  ## ACCESS RIGHTS
  ##

  def may_admin_page?(page = @page)
    current_user.may?(:admin, @page)
  end

  ##
  ## TRASH
  ##

  # ability to move to trash
  # you can change this to be different than destroy, 
  # if you can destroy, you should also be able to delete. 
  alias_method :may_delete_page?, :may_destroy_page?

  # ability to remove from trash
  alias_method :may_undelete_page?, :may_delete_page?

  ##
  ## TAGS
  ##

  alias_method :may_edit_page_tags?, :may_edit_page?

  ##
  ## ASSETS
  ##

  alias_method :may_edit_page_asset?, :may_edit_page?
  #alias_method :may_create_assets?, :may_edit_page? #this is definited in assets_permission.rb too


  ##
  ## DETAILS
  ##
  alias_method :may_show_page_detail?, :may_edit_page?

  ##
  ## SHARING
  ##

  alias_method :may_share_page?, :may_admin_page?
  alias_method :may_notify_page?, :may_edit_page?

  #def may_share_with_all?
  #  !Site.current.try.network.nil? and may_share_page?
  #end

  ##
  ## PARTICIPATION
  ##

  alias_method :may_star_page?, :may_show_page?
  alias_method :may_watch_page?, :may_show_page?
  alias_method :may_public_page?, :may_admin_page?
  alias_method :may_move_page?, :may_admin_page?
  alias_method :may_share_page?, :may_admin_page?

  alias_method :may_create_participation?, :may_admin_page?
  alias_method :may_destroy_participation?, :may_create_participation?
  alias_method :may_show_participation?,    :may_show_page?
  alias_method :may_index_participation?,    :may_show_page?

  # if true, then you can choose access permissions when sharing
  # pages. this is used by cc.net. Not sure if this is a hack
  # or a useful general feature. 
  def may_select_access_participation?(page=@page)
    page.nil? or current_user.may? :admin, page
  end

  # this does not really test permissions, rather, it lets us know if something horrible would
  # happen if we removed this participation. may_admin_page_without is an expensive call,
  # so this should be used sparingly. this method helps prevent removing yourself
  # from page access, although it is clumsy. 
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

  ##
  ## TITLE
  ##

  alias_method :may_update_title?, :may_edit_page? # should be may_update_page_title? ? Or maybe not needed?
  alias_method :may_edit_title?, :may_update_title?

end

