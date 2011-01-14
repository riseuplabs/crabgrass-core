#
#
# Here lie all the helpers for the fancy search form for pages.
#
#

require 'cgi'

module Page::SearchHelper

  def search_filter_sections
    [:my_pages, :access, :properties, :popular_pages, :advanced]
  end

  #def opened_section?(section)
  #  [:my_pages].include?(section)
  #end

  # creates a quick lookup map of filter => true for the currently active filters
  def active_filters
    @active_filters ||= @path.filters.to_h {|f| [f[0],true]}
  end

  # returns true if the filter is active in the current path
  def filter_active?(filter)
    active_filters[filter]
  end

  # returns true if the filter is excluded by a currently active filter
  def filter_excluded?(filter)
    @excluded_filters ||= begin
      @path.filters.to_h {|f| [f[0].exclude, true]}
    end
    if filter.exclude
      @excluded_filters[filter.exclude]
    else
      false
    end
  end

  def possible_filters_for_section(section)
    SearchFilter.filters_for_section(section).select do |filter|
      if filter_excluded?(filter)
        false
      elsif filter.singleton? and filter_active?(filter)
        false
      else
        true
      end
    end
  end

  def filter_all
    SearchFilter['all']
  end

  # if we should show the 'all' filter, return true.
  def show_all?
    @show_all ||= !(@path.filters.detect {|filter,x| filter.has_control_ui?})
  end

  # mode -- :add | :remove
  def filter_checkbox_li_tag(mode, filter, args=nil)
    if filter.has_args?
      filter_multivalue_li_tag(mode, filter, args)
    else
      filter_singlevalue_li_tag(mode, filter)
    end
  end

  # for filters with no args
  def filter_singlevalue_li_tag(mode, filter)
    spinbox_tag(filter.path_keyword, filter.label.t,
      me_pages_path(mode => filter.path_definition),
      :with => 'FilterPath.encode()', :checked => (mode == :remove) )
  end

  # for filters with one or more args
  def filter_multivalue_li_tag(mode, filter, args)
    if mode == :add
      label = filter.label
      html = render(:partial => 'common/pages/search/popup',
        :locals => {:url => me_pages_path(:add => filter.path_definition), :filter => filter})
      link_to_modal(label, :html => html, :icon => 'check_off')
    else
      label = filter.label(args)
      if label
        path = filter.path(args)
        name = filter.name(args)
        spinbox_tag(name, h(label), me_pages_path(:remove => path), :with => 'FilterPath.encode()', :checked => true)
      end
    end
  end

  # a helper used by search filters that define custom a UI.
  # the options come from a member variable @filter_submit_options that
  # is defined in /common/pages/search/_popup
  def filter_submit_button(label, params)
    if params.any?
      options = @filter_submit_options.merge({
        :url => @filter_submit_options[:url] += "&" + params.collect{|key,value| "%s=%s" % [CGI.escape(key.to_s), CGI.escape(value.to_s)] }.join('&')
      })
    else
      options = @filter_submit_options
    end
    submit_to_remote 'submit', label, options
  end

  #
  # a link used in the page search popup. 
  # it creates a form element to match params, then submits the form.
  # this only accepts a single param, but it is in the form {:key => value}
  #
  def link_to_page_search(label, params, options = {})
    name, value = params.to_a.first.map{|i| CGI.escape(i.to_s) }
    function = "$('page_search_form').insert(new Element('input', {name:'%s', value:'%s', style:'display:none'})); $('page_search_form').submit.click();" % [name, value]
    link_to_function(label, function)
  end

  
  #
  # the toggle bug that allows you to change the view of the page search
  # results (compact, detailed, grid). 
  #
  # this uses the special queued ajax request, so that there are no race conditions
  # in modifying the page search.
  # 
  # this is used in _top_controls partial
  #
  def search_view_toggle_links(url)
    with = "FilterPath.encode()"   # grab the current filterpath,
                                   # at the time the request is made, not when it is queued.
    options = {:with => with, :before => show_spinner('view_toggle')}
    current_view = @path.arg_for('view') || 'compact'

    # compact
    function = queued_remote_function options.merge(:url => url+'?add=/view/compact/')
    compact_link = {:label => 'compact', :function => function, :active => current_view == 'compact', :id => 'toggle_view_compact'}
    # detailed
    function = queued_remote_function options.merge(:url => url+'?add=/view/detailed/')
    detailed_link = {:label => 'detailed', :function => function, :active => current_view == 'detailed', :id => 'toggle_view_detailed'}
    # grid
    function = queued_remote_function options.merge(:url => url+'?add=/view/grid/')
    grid_link = {:label => 'grid', :function => function, :active => current_view == 'grid', :id => 'toggle_view_grid'}

    toggle_bug_links(compact_link, detailed_link, grid_link)
  end 

  private

  def spinbox_tag(name, label, url, options = {})
    id = "#{name}_check_link"
    if options[:checked]
      icon = 'check_on'
    else
      icon = 'check_off'
    end
    # we create a queued request because we don't want any race conditions
    # with the requests -- they must be resolved one at a time.
    function = queued_remote_function(
      :url => url,
      :before  => spinner_icon_on(icon, id),
      :with => options[:with]
    )
    content_tag(:li) do
      link_to_function_with_icon(label, function, :url => url, :icon => icon, :id => id)
    end
  end

end

