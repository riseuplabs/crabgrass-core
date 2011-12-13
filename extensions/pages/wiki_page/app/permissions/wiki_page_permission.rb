module WikiPagePermission
  def may_show_wiki_page?(page = @page)
    page.nil? or
    page.public? or
    logged_in? && current_user.may?(:view, page)
  end

  alias_method :may_print_wiki_page?, :may_show_wiki_page?

end
