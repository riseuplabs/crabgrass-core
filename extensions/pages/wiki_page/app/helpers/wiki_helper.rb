module WikiHelper

  ##
  ## VERSIONING
  ##

  def old_version_select_tag(wiki, spinner_id)
    version_labels_values = []
    # [['Version 1', '1'], ['Version 2', '2'],...]
    wiki.versions.each do |version|
      version_labels_values << [wiki_version_label(version), version.version]
    end

    # if we have an old version loaded, we should have that one as the selected one
    # in the options tag. but since we're working with two wikis at once (public and private)
    # the version we're showing is only for one tab and we have to be sure it's for the right wiki
    if @showing_old_version && wiki.versions.include?(@showing_old_version)
      selected_version = @showing_old_version
    else
      selected_version = wiki.versions.last
    end

    select_tag_options = options_for_select(version_labels_values, selected_version.version)
    select_tag_name = 'old_version_select-' + wiki.id.to_s
    select_tag select_tag_name, select_tag_options,
      :onchange => (remote_function(:url => wiki_action('old_version', :wiki_id => wiki.id),
                                      :loading => show_spinner(spinner_id),
                                      :with => "'old_version=' + $('#{select_tag_name}').value",
                                      :confirm => I18n.t(:wiki_lost_text_confirmation)))
  end

  # returns something like 'Version 3 created Fri May 08 12:22:03 UTC 2009 by Blue!'
  def wiki_version_label(version)
    label = I18n.t(:version_number, :version => version.version)
     # add users name
     if version.user_id
       user_name = User.find_by_id(version.user_id).try.name || I18n.t(:unknown)
       label << ' ' << I18n.t(:created_when_by, :when => full_time(version.updated_at), :user => user_name)
     end

     label
  end


  ##
  ## WIKI EDITORS
  ##

  def preferred_editor_tab
    @active_editor_tab ||= begin
      active_tab = current_user.setting.preferred_editor_sym
      if active_tab == :greencloth and !Conf.allow_greencloth_editor?
        active_tab = :html
      elsif active_tab == :html and !Conf.allow_html_editor?
        active_tab = :greencloth
      end
      active_tab
    end
  end

  # why is this logic so complex? different installs want really different things.
  def wiki_editor_tab_label(type)
    if type == :plain
      if Conf.allow_html_editor?
        if Conf.text_editor_sym == :html_preferred
          I18n.t(:wiki_advanced_editor)
        else
          I18n.t(:wiki_plain_editor)
        end
      else
        I18n.t(:wiki_editor)
      end
    else
      if Conf.text_editor_sym == :html_preferred || !Conf.allow_greencloth_editor?
        I18n.t(:wiki_editor)
      else
        I18n.t(:wiki_visual_editor)
      end
    end
  end

  # takes some nice and clean xhtml, and produces some ugly html that is well suited for
  # for the wysiwyg html editor.
  def ugly_html(html)
    UglifyHtml.new( html || "" ).make_ugly
  end

  AVAILABLE_EDITOR_LANGS = %w(b5 ch cz da de ee el es eu fa fi fr gb he hu it ja lt lv nb nl pl pt_br ro ru sh si sr sv th vn).inject({}) {|h,l| h[l]=l; h}

  def html_editor_language_code()
    code = session[:language_code].to_s.downcase
    short_code = code.sub(/_.*$/,'')
    default = 'en'
    AVAILABLE_EDITOR_LANGS[code] || AVAILABLE_EDITOR_LANGS[short_code] || default
  end

end
