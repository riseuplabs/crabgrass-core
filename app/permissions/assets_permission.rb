# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    if @asset
#      if action_name == 'show' || action_name == 'version'
#        current_user.may?(:view, @asset)
#      elsif action_name == 'create' || action_name == 'destroy'
#        current_user.may?(:edit, @asset.page)
#      end
#    else
#      false
#    end
#  end
module AssetsPermission

  protected

  def may_show_asset?
    if @asset
      if params[:code]
        params[:code] == @asset.code
      else
        current_user.may?(:view, @asset)
      end
    else
      false
    end
  end

  def may_create_asset?
    @asset and current_user.may?(:edit, @asset.page)
  end

  alias_method :may_destroy_asset?, :may_create_asset?
end
