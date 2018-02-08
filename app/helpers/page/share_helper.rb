module Page::ShareHelper
  def page_access_options(options = {})
    @access_options ||= [
      [I18n.t(:page_access_admin), 'admin'],
      [I18n.t(:page_access_edit), 'edit'],
      [I18n.t(:page_access_view), 'view']
    ]
    if options[:remove]
      @access_options + [[I18n.t(:page_access_none), 'remove']]
    elsif options[:blank]
      @access_options + [[format('(%s)', I18n.t(:no_change)), '']]
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
      option = page_access_options.find { |option| option[1] == access }
      content_tag :span, option[0], class: access if option
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
  def select_page_access(name, participation = {}, options = nil)
    if participation.is_a?(Hash)
      options = participation
      selected = options[:selected]
    else
      selected = participation.access_sym
    end

    options = options.reverse_merge(blank: true, expand: false, remove: false, class: 'access')
    select_options = page_access_options(blank: options[:blank], remove: options.delete(:remove))
    selected ||= if options.delete(:blank)
                   ''
                 else
                   Conf.default_page_access
                 end
    options[:size] = select_options.size if options.delete(:expand)
    options[:style] = 'width: auto'
    options[:class] = 'form-control'
    select_tag name, options_for_select(select_options, selected.to_s), options
  end

end
