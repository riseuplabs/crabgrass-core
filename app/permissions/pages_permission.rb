module PagesPermission

  protected

  def may_show_page?
    true
  end

  def may_edit_page?
    true
  end

  def may_update_page?
    true
  end

  def may_new_page?
    logged_in?
  end

  def may_create_page?
    logged_in?
  end

  def may_destroy_page?
    true
  end

  def may_index_pages?
    logged_in?
  end

end

