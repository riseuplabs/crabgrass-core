module Wikis::SectionsHelper

  def wiki_body_html(wiki = @wiki)
    html = wiki.body_html
    return html unless logged_in? and current_user.may?(:edit, wiki.page)

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


  def wiki_body_html_with_edit_form(wiki = @wiki, section = @editing_section)
    html = wiki_body_html(wiki).dup

    return html unless show_inline_editor?
    markup_to_edit = wiki.get_body_for_section(section)

    inline_form = render_inline_form(markup_to_edit, section)
    inline_form << "\n"

    # replace section html with the form

    doc = Hpricot(html)

    # this is the heading node we want replace with the forms
    replace_node = find_heading_node(doc, section)
    # everything between replace_node and next_good_node should be deleted

    next_good_node = find_heading_node(doc, wiki.successor_for_section(section).try.name)

    # these nodes should be deleted
    delete_nodes = []

    delete_node = replace_node.next_sibling
    while delete_node != next_good_node and !delete_node.nil?
      delete_nodes << delete_node
      delete_node = delete_node.next_sibling if delete_node
    end

    replace_node.swap(inline_form)
    delete_nodes.each {|node| node.swap('<span></span>')}

    # return the modified html
    doc.to_html
  end

  def render_inline_form(markup, section)
    render :partial => 'edit_inline', :locals => {:markup => markup, :section => section}
  end


  # also defined in app/helpers/wikis/base_helper.rb
  # we might want to combine the two and make them depend on
  # whether it's a page or a group wiki.
  # this is the page wiki case:
#  def wiki_path(wiki = @wiki, options = {})
#    page_xpath(wiki.page, options)
#  end

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

