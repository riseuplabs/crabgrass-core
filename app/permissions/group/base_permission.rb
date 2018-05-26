module Group::BasePermission
  protected

  def may_create_network?
    Conf.networks and logged_in?
  end

end
