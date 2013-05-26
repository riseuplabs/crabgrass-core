module Wikis::SectionsHelper

  def decorate_wiki_sections(wiki, section=:document)
    doc = Hpricot(wiki.body_html)
    doc.search('h4 a.anchor, h3 a.anchor, h2 a.anchor, h1 a.anchor').each do |anchor|
      subsection = anchor['href'].sub(/^.*#/, '')
      add_edit_link_to_heading(wiki, anchor, subsection)
      wrap_in_div(wiki, doc, subsection, section == :document)
    end
    doc.to_html.html_safe
  end

  private

  def find_heading_node(doc, section)
    return nil if section.nil?
    anchor = doc.at("a[@name=#{section}]")
    if anchor.nil?
      raise Wiki::SectionNotFoundError.new(section)
    end
    anchor.parent
  end

  #
  # there are a lot of classes assigned to each edit link:
  # * "wiki-section-edit" is used to hide links when a section is being edited.
  # * "shy" is used to show the link only when the mouse is over
  #
  def add_edit_link_to_heading(wiki, anchor, section)
    heading = anchor.parent
    link = link_to_remote(:edit.t,
      {:url => edit_wiki_path(wiki, :section => section), :method => 'get'},
      :title => :wiki_section_edit.t, :id => "#{section}_edit_link",
      :icon => 'pencil', :class => 'edit shy wiki-section-edit'
    )
    heading.insert_after(Hpricot(link), anchor)
    heading.attributes['class'] += " shy_parent"
  end

  def wrap_in_div(wiki, doc, section, is_full_wiki)
    # this is the heading node we want to wrap with its content
    heading = find_heading_node(doc, section)
    # everything between replace_node and next_node should be wrapped

    end_before = find_heading_node(doc, wiki.successor_for_section(section).try.name) rescue nil

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
    wrap = heading.make("<div id='#{dom_id(wiki, section.underscore)}'></div>").first
    heading.parent.replace_child(heading, wrap)
    wrap.html(to_wrap)
  end

end

