module Page::ShareHelper

  def page_access_options(options={})
    @access_options ||= [
      [I18n.t(:page_access_admin),'admin'],
      [I18n.t(:page_access_edit),'edit'],
      [I18n.t(:page_access_view),'view']
    ]
    if options[:remove]
      @access_options + [[I18n.t(:page_access_none),'remove']]
    elsif options[:blank]
      @access_options + [["(%s)" % I18n.t(:no_change),'']]
    else
      @access_options
    end
  end

  # displays the access level of a participation.
  # eg:
  #   <span class="admin">Full Access</span>
  #
  def display_access(participation)
    if participation
      access = participation.access_sym.to_s
      if access.empty? and @page
        participation = @page.most_privileged_participation_for(participation.entity)
        access = participation.access_sym.to_s
      end
      option = page_access_options.find{|option| option[1] == access}
      if option
        content_tag :span, option[0], class: access
      end
    end
  end

  def display_access_icon(participation)
    icon = case participation.access_sym
      when :admin then 'tiny_wrench'
      when :edit then 'tiny_pencil'
      when :view then 'tiny_no_pencil'
    end
    icon_tag(icon)
  end

  #
  # creates a select tag for page access
  #
  # There are two forms:
  #
  #   select_page_access(name, participation, options)
  #   select_page_access(name, options)
  #
  # options:
  #
  #  [blank] if true, include 'no change' as an option
  #  [expand] if true, show as list instead of popup.
  #  [remove] if true, show an entry that allows for access removal
  #
  def select_page_access(name, participation={}, options=nil)
    if participation.is_a?(Hash)
      options = participation
      selected = options[:selected]
    else
      selected = participation.access_sym
    end

    options = options.reverse_merge(blank: true, expand: false, remove: false, class: 'access')
    select_options = page_access_options(blank: options[:blank], remove: options.delete(:remove))
    if options.delete(:blank)
      selected ||= ''
    else
      selected ||= Conf.default_page_access
    end
    if options.delete(:expand)
      options[:size] = select_options.size
    end
    options[:style] = "width: auto"
    options[:class] = 'form-control'
    select_tag name, options_for_select(select_options, selected.to_s), options
  end

  protected

  def add_action(recipient, access, spinner_id)
    access ||= may_select_access_participation? ?
      "$('recipient[access]').value" :
      "'#{Conf.default_page_access}'"
    {
      url: {controller: 'base_page/share', action: 'update', page_id: nil, add: true},
      with: %{'recipient[name]=#{recipient.name}&recipient[access]=' + #{access}},
      loading: spinner_icon_on('spacer', spinner_id),
      complete: spinner_icon_off('spacer', spinner_id)
      }
  end

  # the remote action that is triggered when the 'add' button is pressed (or
  # the popup item is selected).
  def widget_add_action(action, add_button_id, access_value)
    {
      url: {controller: 'base_page/share', action: action, page_id: @page.id, add: true},
      with: %{'recipient[name]=' + $('recipient_name').value + '&recipient[access]=' + #{access_value}},
      loading: spinner_icon_on('plus', add_button_id),
      complete: spinner_icon_off('plus', add_button_id)
    }
  end

  # (1) submit the form when the enter key is pressed in the text box
  # (2) don't submit the form if the recipient name field is empty
  # (3) eat the event by returning false on a enter key so that the form
  #     is not submitted.
  def add_recipient_widget_autocomplete_tag(add_action)
    # this is called after an item in the popup has been selected.
    # it makes it so selecting an item is like hitting the add button
    # we clear the recipient_name field so that we don't get a double submit
    after_update_function = "function(value, data) { #{remote_function(add_action)}; $('recipient_name').value='';}"

    autocomplete_entity_tag('recipient_name',
                        onselect: after_update_function,
                        message: I18n.t(:entity_autocomplete_tip),
                        container: 'autocomplete_container')
  end

  def add_recipient_widget_key_press_function(add_action)
    eat_enter = "return(!enterPressed(event));"
    only_on_enter_press = "enterPressed(event) && $('recipient_name').value != ''"
    remote_function(add_action.merge(condition: only_on_enter_press)) + eat_enter;
  end

end

