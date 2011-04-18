##
## PAGE FORM HELPERS
##

module Common::Page::FormHelper

  protected

  def display_page_class_grouping(group)
    I18n.t("page_group_#{group.gsub(':','_')}".to_sym)
  end

  #
  # The various page types form a hierarchy.
  # golly, this seems overly complicated.
  #
  # produces a structure that looks like this:
  # [{:pages => [classproxy, classproxy], :display => "Multimedia", :name => "media", :url => "media"},{..}]
  #
  # 
  def tree_of_page_types(options={})
    if @group
      available_page_classes = current_site.tools_for(@group)
    else
      available_page_classes = current_site.available_page_types
    end
    page_groupings = []
    available_page_classes.each do |page_class_string|
      page_class = Page.class_name_to_class(page_class_string)
      next if page_class.nil? or page_class.internal
      if options[:simple]
        page_groupings << page_class.class_group.to_a.first
      else
        page_groupings.concat page_class.class_group
      end
    end
    page_groupings.uniq!
    tree = []
    page_groupings.each do |grouping|
      entry = {:name => grouping, :display => display_page_class_grouping(grouping),
         :url => grouping.gsub(':','-')}
      entry[:pages] = Page.class_group_to_class(grouping).select{ |page_klass|
       !page_klass.internal && available_page_classes.include?(page_klass.full_class_name)
      }.sort_by{|page_klass| page_klass.order }
      tree << entry
    end
    return tree.sort_by{|entry| Crabgrass::Page::ClassProxy::ORDER.index(entry[:name])||100 }
  end

  #
  # options for a page type dropdown menu for searching
  #
  #def options_for_select_page_type(default_selected=nil)
  #  default_selected.sub!(' ', '+') if default_selected
  #  menu_items = []
  #  tree_of_page_types.each do |grouping|
  #    menu_items << [grouping[:display], grouping[:url]]
  #    sub_items = grouping[:pages].collect do |page_class|
  #       ["#{grouping[:display]} > #{page_class.class_display_name}",
  #       "#{grouping[:url]}+#{page_class.url}"]
  #     end
  #     menu_items.concat sub_items if sub_items.size > 1
  #  end
  #  options_for_select([['all page types'.t,'']] + menu_items, default_selected)
  #end

  #
  # options for a page type dropdown menu for searching
  # (this one does not list the types in a tree)
  #
  def options_for_select_page_type(default_selected='')
    available_types = current_site.available_page_types
    menu_items = []
    available_types.each do |klass_name|
      klass = Page.class_name_to_class(klass_name)
      next if klass.nil? or klass.internal
      display_name = klass.class_display_name
      url = klass.url
      menu_items << [display_name, url]
    end
    menu_items.sort!
    options_for_select([[:all_page_types.tcap,'']] + menu_items, default_selected)
  end

#  ## Creates options useable in a select() for the various states
#  ## a page might be in. Used to filter on these states
#  def options_for_page_states(parsed_path)
#    selected = ''
#    selected = 'pending' if parsed_path.keyword?('pending')
#    selected = 'unread' if parsed_path.keyword?('unread')
#    selected = 'starred' if parsed_path.keyword?('starred')
#    selected = parsed_path.first_arg_for('page_state') if parsed_path.keyword?('page_state')
#    options_for_select(['unread','pending','starred'].to_localized_select, selected)
#  end

end
