# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    logged_in? and current_user.member_of?(@group)
#  end
module WikiPermission

  protected

  def may_edit_wiki?(wiki = @wiki)
    logged_in? and current_user.may?(:edit, wiki.context)
  end

  def may_admin_wiki?(wiki = @wiki)
    logged_in? and current_user.may?(:admin, wiki.context)
  end

end

