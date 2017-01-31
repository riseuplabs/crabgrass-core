class Notice::PageUpdateNotice < Notice::PageNotice

  def display_title
    I18n.t(:page_updated, data).html_safe
  end

  def display_body_as_quote?
    false
  end

  def display_body
    ""
  end

  def display_label
    I18n.t :page_update
  end

end
