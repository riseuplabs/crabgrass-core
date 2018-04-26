#
# For showing lists of pages in various ways
#

module Common::Page::ListingHelper
  protected

  #
  # this is a workaround for the missing to_partial_path before rails 3.2
  #
  # In rails 3.2 we'll be able to just set to_partial_path for pages and use
  # render pages, locals
  def render_pages(pages, locals)
    render partial: 'common/pages/page',
           collection: pages,
           as: :page,
           locals: locals
  end

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
