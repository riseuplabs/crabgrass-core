module Common::Ui::GroupsHelper
  #
  # returns a bunch of <option></option> tags usable in a select menu to choose a group.
  #
  # example usage:
  #
  #   select_tag('group_name', options_for_select_group(:include_committees => true))
  #
  # accepted options:
  #
  #  :selected     -- the item to make selected (either string or group object)
  #  :include_me   -- if true, include option for 'me'
  #  :include_none -- if true, include an option for 'none'
  #  :include_committees -- if true, inclue all the committees of each group
  #  :as_admin     -- if true, only include groups current user is an admin for
  #
  #  no options are set by default.
  #
  def options_for_select_group(options = {})
    items = if options[:without_networks]
              current_user.primary_groups
            else
              current_user.primary_groups_and_networks
            end

    items = items.with_admin(current_user) if options[:as_admin]

    items.order(:name)

    # make sure to act on a copy so we do not alter the relation
    items = items.map do |group|
      { value: group.name, label: group.name, group: group }
    end

    selected_item = nil

    if options[:selected]
      if options[:selected].nil?
        # this method was called with :selected => nil indicating that there should be 'none' selected.
        options[:include_none] = true
      elsif options[:selected].is_a? String
        selected_item = options[:selected].sub(' ', '+') # sub '+' for committee names
      elsif options[:selected].respond_to?(:name)
        selected_item = options[:selected].name
      end
    end

    if options[:include_none]
      items.unshift(value: '', label: :none.t, style: 'font-style: italic')
      selected_item ||= ''
    end

    if options[:include_me]
      items.unshift(value: current_user.name, label: format('%s (%s)', I18n.t(:me), current_user.name), style: 'font-style: italic')
      selected_item ||= current_user.name
    end

    unless items.detect { |i| i[:value] == selected_item }
      # we have a problem: item list does not include the one that is supposed to be selected. so, add it.
      items.unshift(value: selected_item, label: selected_item)
    end

    html = []

    items.collect do |item|
      selected = ('selected' if item[:value] == selected_item)
      html << content_tag(
        :option,
        truncate(item[:label], length: 40),
        value: item[:value],
        class: 'spaced',
        selected: selected,
        style: item[:style]
      )
      next unless item[:group] and options[:include_committees]
      item[:group].committees.each do |committee|
        selected = ('selected' if committee.name == selected_item)
        html << content_tag(
          :option,
          '&nbsp; + '.html_safe + truncate(committee.short_name, length: 40),
          value: committee.name,
          class: 'indented',
          selected: selected
        )
      end
    end
    html.join("\n").html_safe
  end
end
