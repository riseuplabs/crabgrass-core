module AssetsPermission

  protected

  def may_show_asset?(asset=@asset)
    asset.try.public? || current_user.may?(:view, asset)
  end

  alias_method :may_destroy_asset?, :may_admin_page?
end
