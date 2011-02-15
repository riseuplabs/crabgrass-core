#
# Helpers for displaying the page sidebar.
#
# available to all page controllers derived from base. 
#

module Pages::SidebarHelper

  protected

  def link_to_user_participation(upart)
    icon = case upart.access_sym
      when :admin : 'tiny_wrench_16'
      when :edit : 'tiny_pencil_16'
      when :view : ''
    end
    label = content_tag :span, upart.user.display_name, :class => icon
    link_to_entity(upart.user, :avatar => 'xsmall', :label => label)
  end

  def link_to_group_participation(gpart)
    icon = case gpart.access_sym
      when :admin : 'tiny_wrench_16'
      when :edit : 'tiny_pencil_16'
      when :view : ''
    end
    label = content_tag :span, gpart.group.display_name, :class => icon
    link_to_entity(gpart.group, :avatar => 'xsmall', :label => label)
  end

  ##
  ## SIDEBAR HELPERS
  ##

  def sidebar_checkbox(text, checked, url, options = {})
    icon = checked ? 'check_on' : 'check_off'
    link_to_remote_with_icon(
      text,
      {:url => url, :method => options[:method], :complete => ''},
      {:icon => icon, :id => options[:id], :title => options[:title]}
    )
  end

  def popup(title, options = {}, &block)
    style = [options.delete(:style), "width:%s" % options.delete(:width)].compact.join("; ")
    block_to_partial('base_page/popup_template', {:style=>style, :id=>''}.merge(options).merge(:title => title), &block)
  end

  ##
  ## SIDEBAR LINES
  ##

  def watch_line
    if may_watch_page?
      existing_watch = (@upart and @upart.watch?) or false
      li_id = 'watch_li'
      checkbox_id = 'watch_checkbox'
      url = page_participations_path(@page, :watch => (!existing_watch).inspect)
      content_tag :li, :id => li_id do
        sidebar_checkbox(I18n.t(:watch_checkbox), existing_watch, url, :id => checkbox_id, :method => 'post')
      end
    end
  end

#  def share_all_line
#    li_id = 'share_all_li'
#    if may_share_with_all?
#      checkbox_id = 'share_all_checkbox'
#      url = {:controller => 'base_page/participation',
#        :action => 'update_share_all',
#        :page_id => @page.id,
#        :add => !@page.shared_with_all?
#      }
#      checkbox_line = sidebar_checkbox(I18n.t(:share_all_checkbox), @page.shared_with_all?, url, :id => checkbox_id, :title => I18n.t(:share_all_checkbox_help))
#      content_tag :li, checkbox_line, :id => li_id, :class => 'small_icon'
#    elsif Site.current.network
      # content_tag :li, check_box_tag(checkbox_id, '1', @page.shared_with_all?, :class => 'check', :disabled => true) + " " + content_tag(:span, I18n.t(:share_all_checkbox), :class => 'a'), :id => li_id, :class => 'small_icon'
#    end
#  end

  def public_line
    if may_public_page?
      url = page_attributes_path(@page, :public => (!@page.public?).inspect)
      content_tag :li, :id => 'public_li' do
        sidebar_checkbox(I18n.t(:public_checkbox),
          @page.public?, url, :id => 'public_checkbox',
          :method => 'put', :title => I18n.t(:public_checkbox_help))
      end
    else
      checked = @page.public? ? 'check_on_16' : 'check_off_16'
      content_tag :li do
        content_tag :span, :class => "a small_icon #{checked}" do
          :public_checkbox.t
        end
      end
    end
  end

  def star_line
    if may_star_page?
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
        link_to_remote_with_icon(label, :url => url, :icon => icon, :method => 'post')
      end
    end
  end

  # used in the sidebar of deleted pages
  def undelete_line
    if may_undelete_page?
      content_tag :li do
        link_to_remote_with_icon(I18n.t(:undelete_from_trash), :url => page_trash_path(@page, :type => 'undelete'), :method => 'put', :icon => 'refresh')
      end
    end
  end

  # used in the sidebar of deleted pages
  def destroy_line
    if may_destroy_page?
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
      @page.assets.collect do |asset|
        link_to_asset(asset, :small, :crop! => '36x36')
      end
      #content_tag :div, column_layout(3, items), :class => 'side_indent'
    elsif may_create_assets?
      ''
    end
  end


  ##
  ## SIDEBAR POPUP LINES
  ##

  # used by ajax show_popup.rjs templates
  #
  # for the popup to display in the right spot, we actually offset it by
  # top: -32px, right: 43px from the natural position of the clicked element.
  #
#  def popup_holder_style
#    page_width, page_height = params[:page].split('x')
#    object_x, object_y      = params[:position].split('x')
#    right = page_width.to_i - object_x.to_i
#    top   = object_y.to_i
#    right += 17
#    top -= 32
#    "display: block; right: #{right}px; top: #{top}px;"
#  end

  # creates a <a> tag with an ajax link to show a sidebar popup
  # and change the icon of the enclosing <li> to be spinning
  # required options:
  #  :label -- the text to show
  #  :icon  -- class of the icon for the <li>
  #  :name  -- the name of the popup
  # optional:
  #  :controller -- controller to call show_popup on
  #

#  def show_popup_link(options)
#    options[:controller] ||= options[:name]
#    show_popup = options[:show_popup] || 'show'
#    popup_url = url_for({
#      :controller => "base_page/#{options.delete(:controller)}",
#      :action => show_popup,# 'show',
#      :popup => true,
#      :page_id => @page.id,
#      :name => options.delete(:name)
#    })
#    #options.merge!(:after_hide => 'afterHide()')
#    title = options.delete(:title) || options[:label]
#    link_to_modal(options.delete(:label), {:url => popup_url, :title => title}, options)
#  end

  # to be included in the popup result for any popup that should refresh the sidebar when it closes.
  # also, set refresh_sidebar to true one the popup_line call
  #def refresh_sidebar_on_close
  #  javascript_tag('afterHide = function(){%s}' % remote_function(:url => {:controller => 'base_page/sidebar', :action => 'refresh', :page_id => @page.id}))
  #end

  # create the <li></li> for a sidebar line that will open a popup when clicked
  # required: 
  # - id
  # - url
  # - label
  # - icon
  def popup_line(options)
    #id = options.delete(:id) || options[:name]
    #li_id     = "#{id}_li"
    #link = show_popup_link(options)
    #content_tag :li, link, :id => li_id
    content_tag :li, :id => options[:id] do
      link_to_modal(options[:label], {:url => options[:url]}, {:icon => options[:icon]})
    end
  end

  def edit_attachments_line
    if may_show_page?
      popup_line(:name => 'assets', :label => I18n.t(:edit_attachments_link), :icon => 'attach', :title => I18n.t(:edit_attachments))
    end
  end

  def edit_tags_line
    if may_update_tags?
      popup_line(:name => 'tags', :label => I18n.t(:edit_tags_link),
        :title => I18n.t(:edit_tags), :icon => 'tag')
    end
  end

  def share_line
    if may_share_page?
      popup_line(
        :id => 'share_li',
        :icon => 'group',
        :label => I18n.t(:share_page_link, :page_class => :page.t),
        :url => page_share_path(@page, :mode => 'share')
      )
    end
  end

  def notify_line
    if may_notify_page?
      popup_line(
        :id => 'notify_li',
        :icon => 'whistle',
        :label => I18n.t(:notify_page_link),
        :url => page_share_path(@page, :mode => 'notify')
      )
    end
  end

  def delete_line
    if may_delete_page?
      popup_line(
        :id => 'trash_li',
        :icon => 'trash',
        :label => I18n.t(:delete_page_link, :page_class => :page.t),
        :url => edit_page_trash_path(@page)
      )
    end
  end

  def details_line
    if may_show_page?
      popup_line(
        :id => 'details_li',
        :icon => 'table',
        :label => I18n.t(:page_details_link, :page_class => :page.t),
        :url => page_details_path(@page)
      )
    end
  end

end
