module AssetPageHistoryPermission

  protected

  def may_show_asset_page_history?
    may_show_page?
  end

  def may_destroy_asset_page_history?
    current_user.may?(:edit, @page)
  end

end
