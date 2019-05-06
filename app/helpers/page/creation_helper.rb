

module Page::CreationHelper
  #
  # generates the links used to choose a page type when creating a page
  #
  def page_creation_links
    tree_of_page_types(simple: true).collect do |grouping|
      content_tag(:h2, grouping[:display]) + content_tag(:div, class: 'hover') do
        grouping[:pages].collect do |page|
          link_text = "<b>#{page.class_display_name}</b><br/>#{page.class_description}"
          url = new_page_path(page_type: page)
          link_to(link_text.html_safe, url, class: "p icon top #{page.icon}_16")
        end.join.html_safe
      end
    end
  end
end
