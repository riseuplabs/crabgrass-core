#
# Helpers for displaying the page sidebar.
# Available in all page views.
#

module Pages::SidebarHelper

  Struct.new 'SidebarCommandGroup', :commands, :rule
  Struct.new 'SidebarCommand', :content, :dom_id, :dom_class

  protected

  ##
  ## ENTITY LINKS
  ##

  def link_to_user_participation(upart)
    icon = case upart.access_sym
           when :admin then 'tiny_wrench_16'
           when :edit then 'tiny_pencil_16'
           when :view then ''
           end
    label = content_tag :span, upart.user.display_name, :class => icon
    link_to_entity(upart.user, :avatar => 'xsmall', :label => label)
  end

  def link_to_group_participation(gpart)
    icon = case gpart.access_sym
           when :admin then 'tiny_wrench_16'
           when :edit then 'tiny_pencil_16'
           when :view then ''
           end
    label = content_tag :span, gpart.group.display_name, :class => icon
    link_to_entity(gpart.group, :avatar => 'xsmall', :label => label)
  end

  ##
  ## Sidebar Commands
  ##

  def sidebar_command_groups
    return [] unless logged_in?
    if @page.deleted?
      [deleted_page_commands]
    else
      [participate_commands, access_commands, admin_commands].compact
    end
  end

  def deleted_page_commands
    group_commands undelete_page, destroy_page, details_page
    # removed in core: history_line
  end

  def participate_commands
    group_commands watch_page, star_page
  end

  def access_commands
    group_commands share_page, notify_page, publish_page, rule: true
  end

  def admin_commands
    group_commands delete_page, details_page, rule: true
    # removed in core: move_line, history_line, view_line
  end

  def group_commands(*args)
    options = args.extract_options!
    Struct::SidebarCommandGroup.new args.compact, options[:rule]
  end


  ##
  ## SIDEBAR HELPERS
  ##

  def sidebar_checkbox(text, url, options = {})
    icon = options[:checked] ? 'check_on' : 'check_off'
    link_to_remote(
      text,
      {:url => url, :method => options[:method], :complete => ''},
      {:icon => icon, :id => options[:id], :title => options[:title]}
    )
  end

  ##
  ## SIDEBAR CHECKBOXES
  ##

  #
  # checkbox to add/remove watched status
  #

  def watch_page
    return unless may_show_page?
    Struct::SidebarCommand.new watch_checkbox, 'watch_li'
  end

  def watch_checkbox
    existing_watch = (@upart and @upart.watch?) or false
    checkbox_id = 'watch_checkbox'
    url = page_participations_path(@page, :watch => (!existing_watch).inspect)
    sidebar_checkbox I18n.t(:watch_checkbox), url,
      id: checkbox_id, method: 'post', checked: existing_watch
  end

  #
  # checkbox to add/remove public
  #

  def publish_page
    if may_admin_page?
      Struct::SidebarCommand.new publish_checkbox, 'public_li'
    else
      Struct::SidebarCommand.new is_public_checkbox
    end
  end

  def publish_checkbox
    url = page_attributes_path(@page, :public => (!@page.public?).inspect)
    sidebar_checkbox I18n.t(:public_checkbox), url,
      id: 'public_checkbox', checked: @page.public?,
      method: 'put', title: I18n.t(:public_checkbox_help)
  end

  def public_checkbox
    icon = @page.public? ? 'check_on_16' : 'check_off_16'
    content_tag :span, :class => "a icon #{icon}" do
      :public_checkbox.t
    end
  end

  #
  # checkbox to add/remove star
  #

  def star_page
    return unless may_show_page?
    Struct::SidebarCommand.new star_link, 'star_li'
  end

  def star_link
    if @upart and @upart.star?
      icon = 'star'
      add = false
      label = I18n.t(:remove_star_link, :star_count => @page.stars_count)
    else
      icon = 'star_empty_dark'
      add = true
      label = I18n.t(:add_star_link, :star_count => @page.stars_count)
    end
    url = page_participations_path(@page, :star => add.inspect)
    link_to_remote(label, {url: url, method: 'post'}, {icon: icon})
  end

  #
  # used in the sidebar of deleted pages
  #
  def undelete_page
    return unless may_admin_page?
    Struct::SidebarCommand.new undelete_link
  end

  def undelete_link
    url = page_trash_path(@page, :type => 'undelete')
    link_to_remote_with_icon I18n.t(:undelete_from_trash),
      url: url, method: 'put', icon: 'refresh'
  end

  #
  # used in the sidebar of deleted pages
  #
  def destroy_page
    return unless may_admin_page?
    Struct::SidebarCommand.new destroy_link
  end

  def destroy_link
    link_to_remote_with_icon :destroy_page_via_shred.t,
      icon: 'minus',
      confirm: destroy_confirmation.t(thing: :page.t),
      url: page_trash_path(@page, type: 'destroy'),
      method: 'put'
  end

  #  def view_line
  #    if @show_print != false
  #      printable = link_to I18n.t(:print_view_link), page_url(@page, :action => "print")
  #      content_tag :li, printable, :class => 'small_icon printer_16'
  #    end
  #  end

  #  def history_line
  #    link = link_to I18n.t(:history), page_url(@page, :action => "page_history")
  #    content_tag :li, link, :class => 'small_icon table_16'
  #  end

  ##
  ## SIDEBAR COLLECTIONS
  ##

  def page_attachments
    if @page.assets.any?
      safe_join @page.assets.collect { |asset|
        link_to_asset(asset, :small, :crop! => '36x36')
      }
      #content_tag :div, column_layout(3, items), :class => 'side_indent'
    elsif may_edit_page?
      ''
    end
  end


  ##
  ## SIDEBAR POPUP LINES
  ##

  #
  # to be included in the popup view for any popup that should refresh the sidebar when it closes.
  # the function, when called, will remove itself.
  #
  def refresh_sidebar_on_close
    javascript_tag('afterHide = function(){%s; afterHide = null;}' % remote_function(:url => page_sidebar_path(@page), :method => :get))
  end

  #
  # create the <li></li> for a sidebar line that will open a popup when clicked
  # required options -- :id, :url, :label, :icon
  #

  def popup_command(options)
    Struct::SidebarCommand.new popup_link(options), options.delete(:id)
  end

  def popup_line(options)
    content_tag :li, :id => options.delete(:id) do
      popup_link(options)
    end
  end

  def popup_link(options)
    options[:after_hide] =
      "if (typeof(afterHide) != 'undefined' || afterHide != null) { afterHide(); }"
    link_to_modal(options.delete(:label), options)
  end

  def edit_attachments_line
    if may_show_page?
      popup_line :name => 'assets',
        :label => :edit_attachments_link.t,
        :icon => 'attach',
        :title => :edit_attachments.t,
        :url => page_assets_path(@page),
        :after_load => 'initAjaxUpload();'
    end
  end

  def edit_tags_line
    if may_edit_page?
      popup_line(
        :id => 'tag_li',
        :icon => 'tag',
        :label => I18n.t(:edit_tags_link),
        :url => page_tags_path(@page)
      )
    end
  end

  def share_page
    if may_admin_page?
      popup_command(
        :id => 'share_li',
        :icon => 'group',
        :label => I18n.t(:share_page_link, :page_class => :page.t),
        :url => page_share_path(@page, :mode => 'share')
      )
    end
  end

  def notify_page
    if may_edit_page?
      popup_command(
        :id => 'notify_li',
        :icon => 'whistle',
        :label => I18n.t(:notify_page_link),
        :url => page_share_path(@page, :mode => 'notify')
      )
    end
  end

  def delete_page
    if may_admin_page?
      popup_command(
        :id => 'trash_li',
        :icon => 'trash',
        :label => I18n.t(:delete_page_link, :page_class => :page.t),
        :url => edit_page_trash_path(@page)
      )
    end
  end

  def details_page
    if may_edit_page?
      popup_command(
        :id => 'details_li',
        :icon => 'page_admin',
        :label => I18n.t(:page_details_link, :page_class => :page.t),
        :url => page_details_path(@page)
      )
    end
  end

end
