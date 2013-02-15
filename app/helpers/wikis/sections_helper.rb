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
    body_html = wiki.body_html
    return body_html unless logged_in? and may_edit_wiki?(wiki)
    decorate_wiki_sections(body_html, :document)
  end

  def wiki_section_html(section = @section)
    section_html = @wiki.get_body_html_for_section(section)
    decorate_wiki_sections(section_html, section)
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

  def decorate_wiki_sections(html, section)
    doc = Hpricot(html)
    doc.search('h4 a.anchor, h3 a.anchor, h2 a.anchor, h1 a.anchor').each do |anchor|
      subsection = anchor['href'].sub(/^.*#/, '')
      add_edit_link_to_heading(anchor, subsection)
      wrap_in_div(doc, subsection, section == :document)
    end
    doc.to_html.html_safe
  end

  def add_edit_link_to_heading(anchor, section)
    heading = anchor.parent
    link_opts = {:url => edit_wiki_section_url(@wiki, section), :method => 'get'}
    link = link_to_remote(:edit.t, link_opts, :title => I18n.t(:wiki_section_edit), :id => "#{section}_edit_link", :icon => 'pencil', :class => 'edit shy')
    heading.insert_after(Hpricot(link), anchor)
    heading.attributes['class'] += " shy_parent"
  end

  def wrap_in_div(doc, section, is_full_wiki)
    # this is the heading node we want to wrap with its content
    heading = find_heading_node(doc, section)
    # everything between replace_node and next_node should be wrapped

    end_before = find_heading_node(doc, @wiki.successor_for_section(section).try.name) rescue nil

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

end

