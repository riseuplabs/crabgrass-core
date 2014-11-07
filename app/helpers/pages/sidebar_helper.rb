#
# Helpers for displaying the page sidebar.
# Available in all page views.
#

module Pages::SidebarHelper

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
    label = content_tag :span, upart.user.display_name, class: icon
    link_to_entity(upart.user, avatar: 'xsmall', label: label)
  end

  def link_to_group_participation(gpart)
    icon = case gpart.access_sym
      when :admin then 'tiny_wrench_16'
      when :edit then 'tiny_pencil_16'
      when :view then ''
    end
    label = content_tag :span, gpart.group.display_name, class: icon
    link_to_entity(gpart.group, avatar: 'xsmall', label: label)
  end

  ##
  ## SIDEBAR HELPERS
  ##

  def sidebar_checkbox(text, checked, url, options = {})
    icon = checked ? 'check_on' : 'check_off'
    link_to_remote(
      text,
      {url: url, method: options[:method], complete: ''},
      {icon: icon, id: options[:id], title: options[:title]}
    )
  end

  ##
  ## SIDEBAR CHECKBOXES
  ##

  #
  # checkbox to add/remove watched status
  #

  def watch_line
    if may_show_page?
      existing_watch = (@upart and @upart.watch?) or false
      li_id = 'watch_li'
      checkbox_id = 'watch_checkbox'
      url = page_participations_path(@page, :watch => (!existing_watch).inspect)
      content_tag :li, :id => li_id do
        sidebar_checkbox(I18n.t(:watch_checkbox), existing_watch, url, :id => checkbox_id, :method => 'post')
      end
    end
  end

  #
  # checkbox to add/remove public
  #
  def public_line
    if may_admin_page?
      url = page_attributes_path(@page, :public => (!@page.public?).inspect)
      content_tag :li, :id => 'public_li' do
        sidebar_checkbox(I18n.t(:public_checkbox),
          @page.public?, url, :id => 'public_checkbox',
          :method => 'put', :title => I18n.t(:public_checkbox_help))
      end
    else
      checked = @page.public? ? 'check_on_16' : 'check_off_16'
      content_tag :li do
        content_tag :span, :class => "a icon #{checked}" do
          :public_checkbox.t
        end
      end
    end
  end

  #
  # checkbox to add/remove star
  #
  def star_line
    if may_show_page?
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
      content_tag :li, :id => 'star_li' do
        link_to_remote(label, {:url => url, :method => 'post'}, {:icon => icon})
      end
    end
  end

  #
  # used in the sidebar of deleted pages
  #
  def undelete_line
    if may_admin_page?
      content_tag :li do
        link_to_remote_with_icon(I18n.t(:undelete_from_trash), :url => page_trash_path(@page, :type => 'undelete'), :method => 'put', :icon => 'refresh')
      end
    end
  end

  #
  # used in the sidebar of deleted pages
  #
  def destroy_line
    if may_admin_page?
      content_tag :li do
        link_to_remote_with_icon(:destroy_page_via_shred.t, :icon => 'minus', :confirm => :destroy_confirmation.t(:thing => :page.t), :url => page_trash_path(@page, :type => 'destroy'), :method => 'put')
      end
    end
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
    javascript_tag('afterHide = function(){%s; afterHide = null;}' % remote_function(url: page_sidebar_path(@page), method: :get))
  end

  #
  # create the <li></li> for a sidebar line that will open a popup when clicked
  # required options -- :id, :url, :label, :icon
  #
  def popup_line(options)
    options[:after_hide] =
      "if (typeof(afterHide) != 'undefined' || afterHide != null) { afterHide(); }"
    content_tag :li, id: options.delete(:id) do
      link_to_modal(
        options.delete(:label),
        options
      )
    end
  end

  def edit_attachments_line
    if may_show_page?
      popup_line name: 'assets',
        label: :edit_attachments_link.t,
        icon: 'attach',
        title: :edit_attachments.t,
        url: page_assets_path(@page),
        after_load: 'initAjaxUpload();'
    end
  end

  def edit_tags_line
    if may_edit_page?
      popup_line(
        id: 'tag_li',
        icon: 'tag',
        label: I18n.t(:edit_tags_link),
        url: page_tags_path(@page)
      )
    end
  end

  def share_line
    if may_admin_page?
      popup_line(
        id: 'share_li',
        icon: 'group',
        label: I18n.t(:share_page_link, page_class: :page.t),
        url: page_share_path(@page, mode: 'share')
      )
    end
  end

  def notify_line
    if may_edit_page?
      popup_line(
        id: 'notify_li',
        icon: 'whistle',
        label: I18n.t(:notify_page_link),
        url: page_share_path(@page, mode: 'notify')
      )
    end
  end

  def delete_line
    if may_admin_page?
      popup_line(
        id: 'trash_li',
        icon: 'trash',
        label: I18n.t(:delete_page_link, page_class: :page.t),
        url: edit_page_trash_path(@page)
      )
    end
  end

  def details_line
    if may_edit_page?
      popup_line(
        id: 'details_li',
        icon: 'page_admin',
        label: I18n.t(:page_details_link, page_class: :page.t),
        url: page_details_path(@page)
      )
    end
  end

end
