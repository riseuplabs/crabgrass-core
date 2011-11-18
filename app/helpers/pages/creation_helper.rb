

module Pages::CreationHelper

  #
  # new_page_path is used for showing the selection of page types.
  #
  # page_creation_path is used for linking to the actual controller that handles creation
  # for a particular page type. It might be the default page creation controller (pages/create),
  # or it could be a custom controller.
  #
  #def page_creation_path(page_class)
  #  controller = page_class.definition.creation_controller || 'pages/create'
  #  url_for(:controller => controller, :action => 'new', :type => page_class.url, :group => params[:group_id])
  #end

  #
  # generates the links used to choose a page type when creating a page
  #
  def page_creation_links
    tree_of_page_types(:simple => true).collect do |grouping|
      content_tag(:h2, grouping[:display]) + content_tag(:div, :class => 'hover') do
        grouping[:pages].collect do |page|
          link_text = "<b>#{page.class_display_name}</b><br/>#{page.class_description}"
          url = new_page_path(:page_type => page, :owner => params[:owner])
          link_to(link_text, url, {:class => "p icon top #{page.icon}_16"})
        end
      end
    end
  end


end

