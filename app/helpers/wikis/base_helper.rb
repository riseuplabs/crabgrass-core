module Wikis::BaseHelper

  #
  # html element options for the main div enclosing the wiki
  #
  def wiki_div(wiki)
    {:id => dom_id(wiki)}
  end

  ##
  ## TABS
  ##

  #
  # note: js events are bound to a.wiki_tab and a.wiki_away
  #
  def wiki_tabs(formy, wiki, options={})
    unless wiki.new_record?
      formy.tab do |t|
        t.label :show.t
        t.url wiki_path(wiki)
        t.id dom_id(wiki, 'show_tab')
        t.active options[:active] == 'show' || action?(:show, :none)
        t.options 'data-remote' => true, 'data-method' => :get, :class => 'wiki_tab wiki_away'
      end
    end
    if may_edit_wiki?(wiki)
      formy.tab do |t|
        t.label :edit.t
        t.url edit_wiki_path(wiki)
        t.id dom_id(wiki, 'edit_tab')
        t.active options[:active] == 'edit' || action?(:edit)
        t.options 'data-remote' => true, 'data-method' => :get, :class => 'wiki_tab' # no wiki_away
      end
      formy.tab do |t|
        t.label :versions.t
        t.url wiki_versions_path(wiki)
        t.id dom_id(wiki, 'versions_tab')
        t.active options[:active] == 'versions' || controller?('wikis/versions')
        t.options 'data-remote' => true, 'data-method' => :get, :class => 'wiki_tab wiki_away'
      end
      if options[:show_print].nil? || options[:show_print]
        formy.tab do |t|
          t.label :print.t
          t.url print_wiki_url(wiki)
        end
      end
    end
  end

  ##
  ## JAVASCRIPT HELPERS
  ##

  def create_wiki_toolbar(wiki)
   "wikiEditAddToolbar('#{dom_id(wiki, 'textarea')}', function() {#{image_popup_function(wiki)}});"
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

  #
  # tiggered by events to .wiki_away elements. see wiki.js
  #
  def confirm_discarding_wiki_edit_text_area(wiki)
    wiki_id = wiki.id
    text_area_id = dom_id(wiki, 'textarea')
    message = I18n.t(:leave_editing_wiki_page_warning)
    %Q[confirmWikiDiscard.setTextArea("#{wiki_id}", "#{text_area_id}", "#{message}");]
  end

  #
  # tiggered by events to .wiki_away elements. see wiki.js
  #
  def release_lock_on_unload(wiki, section=:document)
    unless wiki.new_record?
      url = if section != :document
        wiki_lock_path(wiki, :section => section)
      else
        wiki_lock_path(wiki)
      end
      %Q[wikiLock.autoRelease("#{wiki.id}", "#{url}");]
    end
  end

  #
  # try to guess a good default textarea height
  #
  def wiki_textarea_rows(text, min_height = 8, max_height = 30)
    lines = word_wrap(text||"", 60).count("\n") + 5
    [[lines, max_height].min, min_height].max
  end

  #
  # Called by wikis/show partial.
  # Show a notice if some part of of the wiki is locked.
  #
  def wiki_notice
    if @wiki && !@wiki.section_open_for?(:document, current_user)
      other_user = @wiki.locker_of(:document)
      section_they_have_locked = @wiki.section_edited_by(other_user)
      msg = WikiExtension::Locking::SectionLockedError.new(section_they_have_locked, other_user).to_s
      content_tag(:div, msg, :class => "alert alert-info")
    end
  end

end
