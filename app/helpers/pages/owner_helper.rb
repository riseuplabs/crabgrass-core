module Pages::OwnerHelper

  protected
  
  def change_page_owner
    if may_move_page?
      html = render(:partial => 'pages/details/change_owner')
      link_to_modal(:edit.t, :html => html, :title => :page_create_owner.tcap, :icon => 'pencil')
    end
  end

  # returns option tags usable in a select menu to choose a page owner.
  #
  # There are four types of entries:
  #
  #  (1) groups the user is a (direct or indirect) member of
  #  (2) the user
  #  (3) 'none' if !Conf.ensure_page_owner?
  #  (4) the current owner, even if it doesn't meet one of the other criteria.
  #
  #
  # accepted options:
  #
  #  :selected     -- the item to make selected (either string or group object)
  #  :include_me   -- if true, include option for 'me'
  #  :include_none -- if true, include an option for 'none'
  #
  def options_for_page_owner(options={})
    items = current_user.primary_groups_and_networks.sort { |a, b|
       a.name <=> b.name
    }.collect {|group| {:value => group.name, :label => group.name, :group => group} }

    selected_item = nil

    if options[:selected]
      if options[:selected].nil?
        # this method was called with :selected => nil indicating that there should be no owner.
        options[:include_none] = true
      elsif options[:selected].is_a? String
        selected_item = options[:selected].sub(' ', '+')   # sub '+' for committee names
      elsif options[:selected].respond_to?(:name)
        selected_item = options[:selected].name
      end
    end

    if !Conf.ensure_page_owner?
      options[:include_none] = true
    end

    if options[:include_none]
      items.unshift(:value => '', :label => I18n.t(:none), :style => 'font-style: italic')
      selected_item ||= ''
    end

    if options[:include_me]
      items.unshift(:value => current_user.name, :label => "%s (%s)" % [I18n.t(:only_me), current_user.name], :style => 'font-style: italic')
      selected_item ||= current_user.name
    end

    unless items.detect{|i| i[:value] == selected_item}
      # we have a problem: item list does not include the one that is supposed to be selected. so, add it.
      items.unshift(:value => selected_item, :label => selected_item)
    end

    html = []

    items.collect do |item|
      selected = ('selected' if item[:value] == selected_item)
      html << content_tag(
        :option,
        truncate(item[:label], :length => 40),
        :value => item[:value],
        :class => 'spaced',
        :selected => selected,
        :style => item[:style]
      )
      if item[:group]
        item[:group].committees.each do |committee|
          selected = ('selected' if committee.name == selected_item)
          html << content_tag(
            :option,
            "&nbsp; + " + truncate(committee.short_name, :length => 40),
            :value => committee.name,
            :class => 'indented',
            :selected => selected
          )
        end
      end
    end
    html.join("\n")
  end


=begin
  def select_page_owner
    if may_move_page?
      content_tag(:form,
        select_tag('owner_name',
          options_for_page_owner(:include_me => true, :selected => @page.owner_name),
          :onchange => 'this.form.submit();'
        ) + hidden_field_tag('authenticity_token', form_authenticity_token),
        :action => url_for(:controller => '/base_page/participation', :action => 'set_owner', :page_id => @page.id),
        :method => 'post'
      )
    elsif @page.owner
      h(@page.owner.both_names)
    else
      I18n.t(:none)
    end
  end
=end

end
