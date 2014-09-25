module AssetsPermission

  protected

  def may_show_asset?(asset=@asset)
    asset.try.public? || current_user.may?(:view, asset)
  end

  def may_destroy_asset?(asset=@asset)
    current_user.may?(:admin, asset)
  end
end
