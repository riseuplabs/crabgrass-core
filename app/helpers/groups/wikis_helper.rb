module Groups::WikisHelper

  def group_wiki_toggle
    return unless current_user.member_of?(@group)
    toggle_bug_links(public_wiki_link, private_wiki_link)
  end

  def public_wiki_link
    wiki_link(@group.public_wiki, :public_group_wiki)
  end

  def private_wiki_link
    wiki_link(@group.private_wiki, :private_group_wiki)
  end

  def wiki_link(wiki, wiki_type)
    id = wiki_type
    remote = { :url => wiki_link_url(wiki, wiki_type),
      :update => 'wiki-area',
      :before => show_spinner('view_toggle'),
      :success => hide_spinner('view_toggle') + activate_toggle_bug(id),
      :method => :get }
    { :remote => remote,
      :label => id.t,
      :active => @wiki && (@wiki == wiki),
      :id => id }
    end

  def wiki_link_url(wiki, wiki_type)
    if wiki.nil?
      new_group_wiki_path @group,
      :private => (wiki_type == :private_group_wiki)
    else
      group_wiki_path(@group, wiki)
    end
  end

  # used to mark private and public tabs
  def area_id(wiki)
    'edit_area-%s' % wiki.id
  end

  def wiki_edit_link
    return unless may_edit_group_wiki?(@group)
    # TODO: was this used for section editing?
    # note: firefox uses layerY, ie uses offsetY
    link_to_remote :edit.t,
      { :url => edit_group_wiki_path(@group, @wiki),
        :update => 'wiki-area',
        :method => :get
     #  :with => "'height=' + (event.layerY? event.layerY : event.offsetY)"
      },
      :icon => 'pencil'
  end

  def break_lock_link
    url = edit_group_wiki_path(@group, @wiki, :break_lock => true)
    link_to_remote :break_lock.t,
    { :url => url,
      :update => 'wiki-area',
      :method => :get }
  end

  def wiki_versions_link
    return unless may_edit_group_wiki?(@group)
    link_to_remote :versions.t,
      { :url => wiki_versions_path(@wiki),
        :update => 'wiki-area',
        :method => :get }
  end

  def wiki_more_link
    # the 500 should not be hardcoded. instead we should have sth. like
    # @wiki.body_exceeds_preview?
    return unless @wiki.try.body and @wiki.body.length > Wiki::PREVIEW_CHARS
    link_to_remote :see_more_link.t,
    { :url => group_wiki_path(@group, @wiki),
      :update => 'wiki-area',
      :method => :get},
      :icon => 'plus'
  end

  def wiki_less_link
    # the 500 should not be hardcoded. instead we should have sth. like
    # @wiki.body_exceeds_preview?
    return unless @wiki.try.body and @wiki.body.length > Wiki::PREVIEW_CHARS
    link_to_remote :see_less_link.t,
    { :url => preview_group_wiki_path(@group, @wiki),
      :update => 'wiki-area',
      :method => :get,
    },
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

  # This, and other methods in this file, should not only be accessible to group wikis, as we'll want them accessible to page wikis too.
  def edit_or_locked_partial
    (@wiki.document_open_for? current_user) ? 'common/wiki/edit_area' : 'common/wiki/locked_area' # should we confirm @wiki is set?
  end

  def confirm_discarding_wiki_edit_text_area(text_area_id = nil)
    text_area_id ||= wiki_body_id(@wiki)
    confirm_discarding_text_area(text_area_id,
          ["input[name=break_lock]",
          "input[name=save]",
          "input[name=cancel]",
          "input[name=ajax_cancel]"],
          I18n.t(:leave_editing_wiki_page_warning)
          )

  end

end


