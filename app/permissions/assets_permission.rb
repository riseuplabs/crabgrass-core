module AssetsPermission

  protected

  def may_show_asset?(asset=@asset)
    asset and current_user.may?(:view, asset)
  end

  def may_create_asset?(asset=@asset)
    asset and current_user.may?(:edit, asset)
  end

  alias_method :may_destroy_asset?, :may_create_asset?
end
