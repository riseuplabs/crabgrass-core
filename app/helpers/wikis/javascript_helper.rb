module Wikis::JavascriptHelper
  def render_wiki(page, wiki: @wiki, section: @section, template: :show)
    section = section.presence || :document
    if section == :document
      page.replace_html dom_id(@wiki), partial: "common/wikis/#{template}"
    else
      page.replace_html dom_id(@wiki, section.underscore), partial: "common/wikis/#{template}"
      # don't allow multiple section edits at a time:
      page << "$$('.wiki-section-edit').invoke('hide')"
    end
  end
end
