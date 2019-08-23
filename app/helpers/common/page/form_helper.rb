##
## PAGE FORM HELPERS
##

module Common::Page::FormHelper
  protected

  def display_page_class_grouping(group)
    I18n.t("page_group_#{group.tr(':', '_')}".to_sym)
  end

  #
  # The various page types form a hierarchy.
  # golly, this seems overly complicated.
  #
  # produces a structure that looks like this:
  # [{:pages => [classproxy, classproxy], :display => "Multimedia", :name => "media", :url => "media"},{..}]
  #
  #
  def tree_of_page_types(options = {})
    available_page_classes = Conf.available_page_types
    page_groupings = []
    available_page_classes.each do |page_class_string|
      page_class = Page.class_name_to_class(page_class_string)
      next if page_class.nil? or page_class.internal or page_class.forbid_new
      if options[:simple]
        page_groupings << page_class.class_group.to_a.first
      else
        page_groupings.concat page_class.class_group
      end
    end
    page_groupings.uniq!
    tree = []
    page_groupings.each do |grouping|
      entry = { name: grouping, display: display_page_class_grouping(grouping),
                url: grouping.tr(':', '-') }
      entry[:pages] = Page.class_group_to_class(grouping).select do |page_klass|
        !page_klass.internal && !page_klass.forbid_new && available_page_classes.include?(page_klass.full_class_name)
      end.sort_by(&:order)
      tree << entry
    end
    tree.sort_by { |entry| Crabgrass::Page::ClassProxy::ORDER.index(entry[:name]) || 100 }
  end

  #
  # options for a page type dropdown menu for searching
  # (this one does not list the types in a tree)
  #
  def options_for_select_page_type(default_selected = '')
    available_types = Conf.available_page_types
    menu_items = []
    available_types.each do |klass_name|
      klass = Page.class_name_to_class(klass_name)
      next if klass.nil? or klass.internal
      display_name = klass.class_display_name
      url = klass.url
      menu_items << [display_name, url]
    end
    menu_items.sort!
    options_for_select([[:all_page_types.tcap, '']] + menu_items, default_selected)
  end

end
