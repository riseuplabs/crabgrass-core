require 'cgi'

module Page::SearchHelper

  def search_filter_sections
    [:my_pages, :access, :popular_pages, :advanced]
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
    @excluded_filters[filter.path_keyword]
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

  # mode -- :add | :remove
  def filter_checkbox_li_tag(mode, filter)
    if filter.has_args?
      filter_multivalue_li_tag(mode, filter)
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
  def filter_multivalue_li_tag(mode, filter)
    if mode == :add
      label = filter.label
      html = render(:partial => 'common/pages/search/popup',
        :locals => {:url => me_pages_path(:add => filter.path_definition), :filter => filter})
      link_to_modal(label, :html => html, :icon => 'check_off')
    else
      label = filter.label_from_path(@path)
      if label
        path = @path.segment(filter.path_keyword).to_raw_path
        spinbox_tag(filter.path_keyword, h(label),
          me_pages_path(:remove => path),
          :with => 'FilterPath.encode()', :checked => true)
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

