module Wikis::SectionsHelper

  def wiki_section_text_area
    rows = [word_wrap((@markup||""), 80).count("\n")+4, 30].min
    text_area_tag 'wiki[body]', h(@markup),
      :rows => rows,
      :cols => 60,
      :style => 'width:99%;',
      :id => 'wiki_body'
  end

  def wiki_body_html(wiki = @wiki)
    html = wiki.body_html
    return html unless logged_in? and may_edit_wiki?(wiki)

    doc = Hpricot(html)
    doc.search('h4 a.anchor, h3 a.anchor, h2 a.anchor, h1 a.anchor').each do |anchor|
      section = anchor['href'].sub(/^.*#/, '')
      next unless wiki.all_sections.include? section

      link_opts = {:url => edit_wiki_section_url(@wiki, section), :method => 'get'}
      # if show_inline_editor?
      #   link_opts[:confirm] = I18n.t(:wiki_lost_text_confirmation)
      # end
      link = link_to_remote(:edit.t, link_opts, :title => I18n.t(:wiki_section_edit), :id => "#{section}_edit_link", :icon => 'pencil', :class => 'edit shy')

      heading = anchor.parent
      heading.insert_after(Hpricot(link), anchor)
      heading.attributes['class'] += " shy_parent"
      wrap_in_div(doc, section)
    end
    doc.to_html
  end

  def wrap_in_div(doc, section)
    # this is the heading node we want to wrap with its content
    heading = find_heading_node(doc, section)
    # everything between replace_node and next_node should be wrapped

    end_before = find_heading_node(doc, @wiki.successor_for_section(section).try.name)

    # these nodes should be wrapped
    wrapped_nodes = []

    to_wrap = [heading]
    last = heading
    current = heading.try.next_sibling
    while current != end_before and current
      to_wrap << current
      old = current
      current = current.next_sibling
      old.parent.children.delete(old)
    end
    wrap = heading.make("<div id='#{section.underscore}'></div>").first
    heading.parent.replace_child(heading, wrap)
    wrap.html(to_wrap)
  end

  protected

  def find_heading_node(doc, section)
    return nil if section.nil?
    anchor = doc.at("a[@name=#{section}]")
    if anchor.nil?
      raise Wiki::SectionNotFoundError.new(section)
    end

    anchor.parent
  end
end

