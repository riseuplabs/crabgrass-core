module WikiHelper

  ##
  ## WIKI EDITING POPUPS
  ##

  ## the actions for these popups are defined in ControllerExtension::WikiPopup
  ## because they may be in the wiki_controller or the wiki_page_controller. I am not
  ## sure why we do it that way, but that is how it is.

  def popup_image_list(wiki)
    style = "height:64px;width:64px"
    if @images.any?
      images = @images.select{|img| img.url.any? }
      items = radio_buttons_tag(:image, images.collect do |asset|
        [thumbnail_img_tag(asset, :small, :scale => '64x64'), asset.id]
      end)
      data = images.collect do |asset|
        content_tag(:input, '', :id => "#{asset.id}_thumbnail_data", :value => thumbnail_urls_to_json(asset), :type => 'hidden')
      end.join
      content_tag :div, data + items, :class => 'swatch_list'
    end
  end

  def thumbnail_urls_to_json(asset)
    { :small  => asset.thumbnail(:small).try.url || asset.url,
      :medium => asset.thumbnail(:medium).try.url || asset.url,
      :large  => asset.thumbnail(:large).try.url || asset.url,
      :full   => asset.url }.to_json
  end

  def insert_image_function(wiki)
    "insertImage('%s');" % wiki.id
  end

  def image_popup_upload_url(wiki)
    # this method is used both by WikiPageController and WikiPage to
    # upload files to the image insert popup
    if @page and @page.data and @page.data == wiki
      page_xurl(@page, :action => 'image_popup_upload', :wiki_id => wiki.id)
    else
      url_for(wiki_action('image_popup_upload', :wiki_id => wiki.id).merge({:escape => false}))
    end
  end

  def image_popup_show_url(wiki)
    # this method is used both by WikiPageController and WikiPage to show the
    # image insert popup
    if @page and @page.data and @page.data == wiki
      page_xurl(@page, :action => 'image_popup_show', :wiki_id => wiki.id)
    else
      url_for(wiki_action('image_popup_show', :wiki_id => wiki.id).merge({:escape => false}))
    end
  end

  def link_popup_show_url(wiki)
    if @page and @page.data and @page.data == wiki
      page_xurl(@page, :action => 'link_popup_show', :wiki_id => wiki.id)
    else
      url_for(wiki_action('link_popup_show', :wiki_id => wiki.id).merge({:escape => false}))
    end
  end

  def update_link_function(wiki,action)
    "updateLink('%s','%s');" % [wiki.id,action]
  end

  #
  # these functions are used by the toolbar plugins to show the modalbox popups.
  #
  def toolbar_insert_image_function(wiki)
    %(insertImageFunction = function() {
      var editor = new HtmlEditor(#{wiki.id});
      editor.saveSelection();
      #{modalbox_function(image_popup_show_url(@wiki), :title => I18n.t(:insert_image))};
    })
  end

  def toolbar_create_link_function(wiki)
    %(createLinkFunction = function() {
      var editor = new HtmlEditor(#{wiki.id});
      editor.saveSelection();
      #{modalbox_function(link_popup_show_url(@wiki), :title => I18n.t(:add_link))};
    })
  end

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

  #moved wiki_more_link, wiki_less_link, wiki_action and wiki_edit_link to wiki_helper in widget directory

  #this also exists in app/helpers/groups/wikis_helper.rb
  #probably should combine in app/helpers/wikis/base_helper.rb
  def wiki_edit_link
    return unless may_edit_wiki?(@wiki)
    link_to_remote :edit.t,
    {:url => #edit_page_wiki_path(@wiki), #see paths.rb page_xpath app/controllers/common/application/paths.rb
      wiki_path(@wiki, :action => :edit),
      :method => 'get'},
    {:icon => 'pencil'}

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
