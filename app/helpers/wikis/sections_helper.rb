module Wikis::SectionsHelper
  def decorate_wiki_sections(wiki, section = :document)
    decorator = Wiki::Decorator.new wiki, self
    decorator.decorate section
    decorator.to_html.html_safe
  end

  def edit_wiki_section_link(wiki, section)
    link_to :edit.t, edit_wiki_path(wiki, section: section),
      remote: true,
      method: 'get',
      title: :wiki_section_edit.t,
      id: "#{section}_edit_link",
      icon: 'pencil',
      class: 'edit shy wiki-section-edit'
  end
end
