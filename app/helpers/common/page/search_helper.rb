#
#
# Here lie all the helpers for the fancy search form for pages.
#
# For many of the methods in this helper to work, 'page_search_path()' must be defined.
# Typically, this will call me_pages_path or group_pages_path.
#

require 'cgi'

module Common::Page::SearchHelper

  protected

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

  #
  # Returns true if the specified filter should not be shown.
  #
  # There are two reasons to hide a filter:
  #
  # (1) some filters are incompatible with other filters. The filter definition
  #     for these filters will include filter.exclude. This will be a symbol
  #     that defines a set of mutually exclusive filters (e.g. :popular_pages).
  # (2) the current controller can define 'include_filter?(filter)'. If it returns
  #     false, then the filter is excluded.
  #
  def filter_excluded?(filter)
    @excluded_filters ||= begin
      @path.filters.to_h {|f| [f[0].exclude, true]}
    end
    if !show_filter?(filter)
      true
    elsif filter.exclude
      @excluded_filters[filter.exclude]
    else
      false
    end
  end

  def possible_filters_for_section(section)
    enabled, disabled = [], []
    SearchFilter.filters_for_section(section).each do |filter|
      if filter_active?(filter)
         # ignore?
      elsif filter_excluded?(filter)
        disabled.push(filter)
      else
        enabled.push(filter)
      end
    end
    return [enabled, disabled]
  end

  def filter_all
    SearchFilter['all']
  end

  #
  # if we should show the 'all' filter, return true.
  #
  def show_all?
    @show_all ||= !(@path.filters.detect {|filter,x| filter.has_label?})
  end

  #
  # mode: must be :add or :remove
  #
  def filter_checkbox_li_tag(mode, filter, args=nil, options={})
    if filter.has_args?
      filter_multivalue_li_tag(mode, filter, args, options)
    else
      filter_singlevalue_li_tag(mode, filter, options)
    end
  end

  #
  # for filters with no args
  #
  def filter_singlevalue_li_tag(mode, filter, options)
    label = filter.label(nil, {mode => true, :current_user => current_user})
    if options[:disabled]
      link_to_function(label, '', icon: 'check_off', class: 'disabled')
    else
      spinbox_tag(filter.path_keyword,
        page_search_path(mode => filter.path_definition),
        label: label,
        with: 'FilterPath.encode()',
        checked: (mode == :remove) )
    end
  end

  #
  # for filters with one or more args
  #
  def filter_multivalue_li_tag(mode, filter, args, options)
    label = filter.label(args, {mode => true, :current_user => current_user})
    if options[:disabled]
      link_to_function(label, '', icon: 'check_off', class: 'disabled')
    elsif mode == :add
      html = render(partial: 'common/pages/search/popup',
        locals: {url: page_search_path(add: filter.path_definition), filter: filter})
      link_to_modal(label, html: html, icon: 'check_off')
    elsif mode == :remove
      if label
        path = filter.path(args)
        name = filter.name(args)
        spinbox_tag(name, page_search_path(remove: path),
          label: label,
          with: 'FilterPath.encode()',
          checked: true)
      end
    end
  end

  # a helper used by search filters that define custom a UI.
  # the options come from a member variable @filter_submit_options that
  # is defined in /common/pages/search/_popup
  def filter_submit_button(label, params)
    if params.any?
      options = @filter_submit_options.merge({
        url: (@filter_submit_options[:url] += "&" + safe_join(params.collect{|key,value| "%s=%s" % [CGI.escape(key.to_s), CGI.escape(value.to_s)] }, '&')).html_safe
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
    # we need to encode the values so you can't XSS out of the js function
    name, value = params.to_a.first.map{|i| CGI.escape(i.to_s) }
    # we need to decode the values when they are inserted into the form so
    # the form submission does not lead to duplicate encoding...
    function = "$('page_search_form').insert(new Element('input', {name:decodeURIComponent('%s'), value:decodeURIComponent('%s'), style:'display:none'})); $('page_search_form').submit.click();" % [name, value]
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
    options = {with: with, before: show_spinner('view_toggle')}
    current_view = @path.arg_for('view') || 'compact'

    # compact
    function = queued_remote_function options.merge(url: url+'?add=/view/compact/')
    compact_link = {label: 'compact', function: function, active: current_view == 'compact', id: 'toggle_view_compact'}
    # detailed
    function = queued_remote_function options.merge(url: url+'?add=/view/detailed/')
    detailed_link = {label: 'detailed', function: function, active: current_view == 'detailed', id: 'toggle_view_detailed'}
    # grid
    #function = queued_remote_function options.merge(:url => url+'?add=/view/grid/')
    #grid_link = {:label => 'grid', :function => function, :active => current_view == 'grid', :id => 'toggle_view_grid'}

    # toggle_bug_links(compact_link, detailed_link, grid_link)
    toggle_bug_links(compact_link, detailed_link)
  end


end

