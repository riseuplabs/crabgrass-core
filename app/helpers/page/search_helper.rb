module Page::SearchHelper

  #
  # The filter path segments that might be part of the query.
  # The order determines how they are displayed.
  #
  def possible_filter_definitions
    @filters ||= [
      ## {:name => 'all', :label => 'all pages', :path => []},
      {:name => 'created_by_me', :label => 'created by me', :path => ['created_by', current_user.login]},
      {:name => 'type_wiki', :label => 'wikis', :path => ['type','wiki']},
      {:name => 'public', :label => 'public', :path => ['public']}
    ]
  end

  def filter_all
    # possible_filter_definitions.first
    {:name => 'all', :label => 'all pages', :path => ['all']}
  end

  # mode -- :add | :remove
  def filter_checkbox_li_tag(mode, filter)
    spinbox_tag(
      filter[:name],
      filter[:label],
      me_pages_path(mode => filter[:path]),
      :with => 'FilterPath.encode()',
      :checked => (mode == :remove)
      # :id => filter_checkbox_id(filter)
    )
  end

  #def filter_checkbox_id(filter)
  #  "#{filter[:name]}_filter_checkbox"
  #end

  # returns a filter definition matching the path segment.
  def get_filter_definition(path_segment)
    segment = if path_segment.is_a?(PathFinder::ParsedPath)
      path_segment.first
    else
      path_segment
    end
    possible_filter_definitions.each do |filter|
      return filter if filter[:path] == segment
    end
    return nil
  end

end

