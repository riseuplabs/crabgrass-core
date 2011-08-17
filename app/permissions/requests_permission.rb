module RequestsPermission

  protected

  def may_destroy_request?(req=@request)
    logged_in? and req.may_destroy?(current_user)
  end

  def may_update_request?(req=@request)
    logged_in? and (req.may_approve?(current_user) or req.may_vote?(current_user))
  end

  def may_show_request?(req=@request)
    logged_in? and req.may_view?(current_user)
  end

end
