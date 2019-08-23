#
# For showing lists of pages in various ways
#

module Common::Page::ListingHelper
  protected

  def partial_from_style(style)
    case style
    when Symbol, String
      "common/pages/page_#{style}"
    else
      'common/pages/page_table_row'
    end
  end

  def page_tags(page = @page, join = nil)
    join ||= "\n" if join.nil?
    if page.tags.any?
      links = page.tags.collect do |tag|
        tag_link(tag, page.owner)
      end
      links = join != false ? safe_join(links, join) : links
    end
  end

  def cell_title(page)
    link_to(force_wrap(page.title), page_path(page))
  end

end
