module Common::Ui::AutocompleteHelper

  #
  # creates the javascript for autocomplete on text field with field_id
  #
  # required:
  #   field_id  -- the dom id of the text_field tag
  #
  # options:
  #  :keypress  -- js function when key is pressed.
  #  :onselect  -- what js function to run when an item is selected
  #  :message   -- the message to display, if any, before a user starts to type.
  #  :container -- the dom id of an element that will be the container for the popup. optional
  #

#  def autocomplete_entity_tag(field_id, options={})
#    options[:url] ||= '/entities'
#    options[:onselect] ||= 'null'
#    auto_complete_js = %Q[
#      new Autocomplete('#{field_id}', {
#        serviceUrl:'#{options[:url]}',
#        minChars:2,
#        maxHeight:400,
#        width:300,
#        onSelect: #{options[:onselect]},
#        message: '#{escape_javascript(options[:message])}',
#        container: '#{options[:container]}',
#        preloadedOnTop: true,
#        rowRenderer: #{render_entity_row_function},
#        selectValue: #{extract_value_from_entity_row_function}
#      });
#    ]
#    javascript_tag(auto_complete_js)
#  end

  # autocomplete that submits the form on select
  def autocomplete_input_tag(attribute, entities, options = {})
    options.reverse_merge!  autoSubmit: true,
      container: 'autocomplete_container',
      onkeypress: false
    options[:view] = entities
    autocomplete_entity_field_tag(attribute, options)
  end

  # this searches on recipients - people you may pester.
  def autocomplete_recipients_field_tag(field_id, options = {})
    options.merge! view: 'recipients'
    autocomplete_entity_field_tag(field_id, options) #should this always be recipients?
  end

  # just for groups
  def autocomplete_groups_field_tag(field_id, options = {})
    options.merge! view: 'groups'
    autocomplete_entity_field_tag(field_id, options)
  end

  # just for group members
  def autocomplete_members_field_tag(field_id, options = {})
    options.merge! view: 'members'
    autocomplete_entity_field_tag(field_id, options)
  end

  # for groups and users
  def autocomplete_entity_field_tag(field_id, options={})
    # setup options
    options[:view] ||= 'all'
    options[:class] = 'form-control'
    if options[:placeholder].is_a? Symbol
      key = "autocomplete.placeholder.#{options[:placeholder]}"
      options[:placeholder] = I18n.t(key, cascade: true)
    end
    if options[:onkeypress].nil? && options[:onkeydown].nil? && options[:autoSubmit].nil?
      options[:onkeypress] = eat_enter
    end
    js_options = options.extract!(:url, :view, :group, :onselect, :container, :autoSubmit)
    # create input and script tag
    value = options.delete(:value)
    text_field_tag(field_id, value, options) +
      autocomplete_js_tag(options[:id] || field_id, js_options)
  end

  def autocomplete_js_tag(field_id, options)
    path_options = options.extract! :view, :group
    path_options[:format] = 'json'
    url = options.delete(:url) || entities_path(path_options)

    options.select! { |_, v| !v.nil? }
    onselect = options.delete :onselect
    option_string = options.to_json
    if onselect.present?
      option_string = option_string.sub(/}$/, ", onSelect: #{onselect}}")
    end
    javascript_tag("cgAutocompleteEntities('%s', '%s', %s)" % [
      field_id, url, option_string ])
  end

  private

  # called in order to render a popup row. it is a little too complicated.
  #
  # basically, we want to just highlight the text but not the html tags in the
  # popup row.
  #
  def render_entity_row_function
    %Q[function(value, re, data) {return '<p class=\"name_icon xsmall\" style=\"background-image: url(/avatars/'+data+'/xsmall.jpg)\">' + value.replace(/^<em>(.*)<\\/em>(<br\\/>(.*))?$/gi, function(m, m1, m2, m3){return '<em>' + Autocomplete.highlight(m1,re) + '</em>' + (m3 ? '<br/>' + Autocomplete.highlight(m3, re) : '')}) + '</p>';}]
  end

  # called to convert the row data into a value
  def extract_value_from_entity_row_function
    %Q[function(value){return value.replace(/<em>(.*)<\\/em>.*/g,'$1');}]
  end

end
