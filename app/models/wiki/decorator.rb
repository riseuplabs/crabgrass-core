require 'nokogiri'

class Wiki::Decorator
  delegate :to_html, to: :doc

  def initialize(wiki, view)
    @wiki = wiki
    @doc = Nokogiri::HTML.fragment(wiki.body_html)
    @view = view
  end

  def decorate(section)
    doc.search('h4 a.anchor, h3 a.anchor, h2 a.anchor, h1 a.anchor').each do |anchor|
      subsection = anchor['href'].sub(/^.*#/, '')
      add_edit_link_to_heading(wiki, anchor, subsection)
      wrap_in_div(wiki, doc, subsection, section == :document)
    end
    doc
  end

  protected

  attr_reader :wiki, :doc, :view

  def find_heading_node(doc, section)
    return nil if section.nil?
    anchor = doc.at %(a[@name="#{section}"])
    raise Wiki::SectionNotFoundError.new(section) if anchor.nil?
    anchor.parent
  end

  #
  # there are a lot of classes assigned to each edit link:
  # * "wiki-section-edit" is used to hide links when a section is being edited.
  # * "shy" is used to show the link only when the mouse is over
  #
  def add_edit_link_to_heading(wiki, anchor, section)
    heading = anchor.parent
    link = view.edit_wiki_section_link(wiki, section)
    anchor.add_next_sibling link
    heading['class'] = "#{heading['class']} shy_parent"
  end

  def wrap_in_div(wiki, doc, section, _is_full_wiki)
    # this is the heading node we want to wrap with its content
    heading = find_heading_node(doc, section)
    # everything between heading and end_node should be wrapped
    end_before = begin
                   find_heading_node(doc, wiki.successor_for_section(section).try.name)
                 rescue
                   nil
                 end

    wrap = Nokogiri.make view.div_for(wiki, section.underscore)
    heading.previous = wrap
    current = wrap.try.next
    while current != end_before and current
      wrap << current
      current = wrap.next
    end
  end
end
