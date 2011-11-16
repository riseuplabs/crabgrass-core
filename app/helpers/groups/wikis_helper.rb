module Groups::WikisHelper

  def private_wiki_toggle
    wiki_toggle @group.private_wiki, :private_group_wiki
  end

  def public_wiki_toggle
    wiki_toggle @group.public_wiki, :public_group_wiki
  end

  def wiki_toggle(wiki, wiki_type)
    open = @wiki && (@wiki == wiki)
    link_to_toggle wiki_type.t, dom_id(wiki),
      :onvisible => wiki_remote_function(wiki, wiki_type),
      :class => 'section_toggle',
      :open => open do
      if open
        render :partial => 'common/wiki/show', :locals => {:preview => true}
      end
    end
  end

  def wiki_remote_function(wiki, wiki_type)
    remote_function :url => wiki_link_url(wiki, wiki_type, :preview => true),
      :before => show_spinner(wiki),
      :method => :get
  end

  def wiki_link_url(wiki, wiki_type, options = {})
    if wiki.nil?
      new_group_wiki_path @group,
      :private => (wiki_type == :private_group_wiki)
    else
      group_wiki_path(@group, wiki, options)
    end
  end

  def wiki_edit_link
    return unless may_edit_group_wiki?(@group)
    link_to_remote :edit.t,
      { :url => edit_group_wiki_path(@group, @wiki),
        :method => :get
        # This probably was used for section editing
        # note: firefox uses layerY, ie uses offsetY
        # :with => "'height=' + (event.layerY? event.layerY : event.offsetY)"
      },
      :icon => 'pencil'
  end

  def break_lock_link
    url = edit_group_wiki_path(@group, @wiki, :break_lock => true)
    link_to_remote :break_lock.t,
    { :url => url,
      :method => :get }
  end

  def wiki_versions_link
    return unless may_edit_group_wiki?(@group)
    link_to_remote :versions.t,
      { :url => wiki_versions_path(@wiki),
        :update => dom_id(@wiki),
        :method => :get }
  end

  def wiki_more_link
    return unless @wiki.try.body and @wiki.body.length > Wiki::PREVIEW_CHARS
    link_to_remote :see_more_link.t,
    { :url => group_wiki_path(@group, @wiki),
      :method => :get},
      :icon => 'plus'
  end

  def wiki_less_link
    return unless @wiki.try.body and @wiki.body.length > Wiki::PREVIEW_CHARS
    link_to_remote :see_less_link.t,
    { :url => group_wiki_path(@group, @wiki, :preview => true),
      :method => :get},
    :icon => 'minus'
  end

  #from extensions/pages/wiki_page/app/helpers/wiki_helper.rb
  def wiki_locked_notice(wiki)
    return if wiki.document_open_for? current_user

    error_text = I18n.t(:wiki_is_locked, :user => wiki.locker_of(:document).try.name || I18n.t(:unknown))
    %Q[<blockquote class="error">#{h error_text}</blockquote>]
  end

  #next 3 methods from extensions/pages/wiki_page/app/helpers/wiki_helper.rb
# maybe we dont' want them
  def image_popup_id(wiki)
    'image_popup'
  end

  def wiki_body_id(wiki)
    'wiki_body'
  end

  def wiki_toolbar_id(wiki)
    'markdown_toolbar'
  end

  # also from extensions/pages/wiki_page/app/helpers/wiki_helper.rb, also copied as a trial
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

  # also from extensions/pages/wiki_page/app/helpers/wiki_helper.rb, also copied as a trial
  def create_wiki_toolbar(wiki)
    body_id = wiki_body_id(wiki)
    toolbar_id = wiki_toolbar_id(wiki)
    image_popup_code = modalbox_function(new_wiki_image_path(wiki), :title => I18n.t(:insert_image))

   "wikiEditAddToolbar('#{body_id}', '#{toolbar_id}', '#{wiki.id.to_s}', function() {#{image_popup_code}});"
  end

  def confirm_discarding_wiki_edit_text_area(text_area_id = nil)
    text_area_id ||= 'wiki_body'
    saving_selectors = ["input[name=break_lock]",
          "input[name=save]",
          "input[name=cancel]",
          "input[name=ajax_cancel]"]
    message = I18n.t(:leave_editing_wiki_page_warning)
    %Q[confirmDiscardingTextArea("#{text_area_id}", "#{message}", #{saving_selectors.inspect});]
  end

  def release_lock_on_unload
    %Q[releaseLockOnUnload(#{@wiki.id},"#{form_authenticity_token}");]
  end

end


