module Wikis::BaseHelper

  # to be called with a formy tab set like this:
  #
  #   formy(:tabs,...) do |f|
  #     wiki_tabs(f, wiki)
  #   end
  #
  def wiki_tabs(formy, wiki)
    formy.tab do |t|
      t.label :show.t
      t.function remote_function(:url => wiki_path(wiki), :method => 'get')
      t.selected action?(:show)
      t.class 'reloadable'
    end
    formy.tab do |t|
      t.label :edit.t
      t.function remote_function(:url => edit_wiki_path(@wiki), :method => 'get')
      t.show_tab dom_id(@wiki)
      t.selected action?(:edit)
      t.class 'reloadable'
    end
    formy.tab do |t|
      t.label :versions.t
      t.function remote_function(:url => wiki_versions_path(@wiki), :method => 'get')
      t.show_tab dom_id(@wiki)
      t.selected controller?('wikis/versions')
      t.class 'reloadable'
    end
    formy.tab do |t|
      t.label :print.t
      t.url print_wiki_url(wiki)
    end
  end

  def break_lock_link
    url = @section ?
      edit_wiki_section_path(@wiki, @section, :break_lock => true) :
      edit_wiki_path(@wiki, :break_lock => true)
    link_to_remote :break_lock.t,
    { :url => url,
      :method => :get }
  end

  def wiki_locked_notice(wiki)
    return if wiki.document_open_for? current_user

    user = wiki.locker_of(:document).try.name || I18n.t(:unknown)
    error_text = :wiki_is_locked.t(:user => user)
    %Q[<blockquote class="error">#{h error_text}</blockquote>]
  end

  # returns something like
  # 'Version 3 created Fri May 08 12:22:03 UTC 2009 by Blue!'
  def wiki_version_label(version)
    label = :version_number.t(:version => version.version)
    user_name = version.try.user.name || :unknown.t
    label << ' '
    label << :created_when_by.t(:when => full_time(version.updated_at),
      :user => user_name)
    label
  end

  def create_wiki_toolbar(wiki)
   "wikiEditAddToolbar('#{wiki.id.to_s}', function() {#{image_popup_function(wiki)}});"
  end

  def image_popup_function(wiki)
    if wiki.new_record?
      "alert('%s');" % :save_wiki_before_adding_image.t
    else
      modalbox_function new_wiki_asset_path(wiki),
        :title => I18n.t(:insert_image),
        :complete => "initAjaxUpload();"
    end
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
    if @section
      %Q[releaseLockOnUnload(#{@wiki.id},"#{form_authenticity_token}", "#{@section}");]
    else
      %Q[releaseLockOnUnload(#{@wiki.id},"#{form_authenticity_token}");]
    end
  end

  # These are group only but might be called from a generic place such as
  # Wikis::SectionsController for a xhr update

  def wiki_more_link
    return unless @wiki.group
    return unless @wiki.try.body and @wiki.body.length > Wiki::PREVIEW_CHARS
    link_to_remote :see_more_link.t,
      { :url => group_wiki_path(@group, @wiki),
        :method => :get},
      :icon => 'plus'
  end

  def wiki_less_link
    return unless @wiki.group
    return unless @wiki.try.body and @wiki.body.length > Wiki::PREVIEW_CHARS
    link_to_remote :see_less_link.t,
      { :url => group_wiki_path(@group, @wiki, :preview => true),
        :method => :get},
      :icon => 'minus'
  end

end
