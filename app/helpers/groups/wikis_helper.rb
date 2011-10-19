module Groups::WikisHelper

  def group_wiki_toggle
    return unless current_user.member_of?(@group)
    toggle_bug_links(*wiki_or_create_links)
  end

  def group_wiki_tabs
    return unless current_user.member_of?(@group)
    wikis_or_create_link(@group.private_wiki, @group.public_wiki)
  end

  def group_wiki_content
    if @wiki
      render :partial => '/common/wiki/show'
    else
      render :partial => '/common/wiki/blank'
    end
  end

  def wiki_or_create_links
    wikis = [@group.private_wiki, @group.public_wiki].compact
    links = wikis.map{|wiki| wiki_toggle_link(wiki)}
    links.first[:active] = true if wikis.any?
    unless wikis.count == 2
      links += wiki_create_link
    end
    links
  end

  def wiki_toggle_link(wiki)
    label = wiki.profile.private? ?
      :private_group_wiki.t :
      :public_group_wiki.t
    remote = {
      :url => group_wiki_path(@group, wiki),
      :method => :get }
    { :label => label,
      :remote => remote }
  end

  def wiki_create_link
    remote = { :url => new_group_wiki_path(@group),
        :method => :get }
    label = if @wiki.nil?
              :create_group_wiki.t
            elsif @wiki.profile.public?
              :create_public_group_wiki.t
            else
              :create_private_group_wiki.t
            end
    { :remote => remote,
      :lable => label }
  end

  def wikis_or_create_link(*wikis)
    wikis.compact!
    case wikis.compact.count
    when 0
      create_link
    when 1
      wiki_and_create_tabs(wikis.first)
    when 2
      wiki_tabs(*wikis)
    end
  end

  def create_link
    link_to :create_group_wiki.t, new_group_wiki_path(@group)
  end

  def wiki_and_create_tabs(wiki)
    formy :tabs do |f|
      wiki_tab(f, wiki)
      create_wiki_tab(f, wiki.profile.private?)
    end
  end

  def wiki_tabs(*wikis)
    formy :tabs do |f|
      wikis.each_with_index do |wiki, i|
        wiki_tab(f, wiki, i)
      end
    end
  end

  def wiki_tab(f, wiki, index = 0)
    label = wiki.profile.private? ?
      :private_group_wiki.t :
      :public_group_wiki.t
    function = remote_function :url => group_wiki_path(@group, wiki),
      :method => :get
    f.tab do |t|
      t.label label
      t.function function
      t.selected(index == 0)
    end
  end

  def create_wiki_tab(f, is_public = true)
    label = is_public ?
      :create_public_group_wiki.t :
      :create_private_group_wiki.t
    function = remote_function :url => new_group_wiki_path(@group),
      :method => :get
    f.tab do |t|
      t.label label
      t.function function
      t.selected false
    end
  end

  # used to mark private and public tabs
  def area_id(wiki)
    'edit_area-%s' % wiki.id
  end

  def edit_wiki_link
    return unless may_edit_group_wiki?(@group)
    # TODO: was this used for section editing?
    # note: firefox uses layerY, ie uses offsetY
    link_to_remote :edit.t,
      { :url => edit_group_wiki_path(@group, @wiki),
        :method => :get
     #  :with => "'height=' + (event.layerY? event.layerY : event.offsetY)"
      },
      :icon => 'pencil'
  end

  #def wiki_action(action, hash={}) #not clear if we actually want this
    # {:controller => 'widget/wiki', :action => action, :group_id => @group.id, :profile_id => (@profile ? @profile.id : nil)}.merge(hash)
    # {:controller => 'common/wiki', :action => action, :group_id => @group.id, :profile_id => (@profile ? @profile.id : nil)}.merge(hash)
  #end

  def wiki_more_link
    return unless @wiki.try.body and @wiki.body.length > 500
    link_to_remote I18n.t(:see_more_link) ,
      { :url => group_wiki_path(@group, @wiki) },
      :icon => 'plus'
  end

  def wiki_less_link
    return unless @wiki.try.body and @wiki.body.length > 500
    link_to_remote I18n.t(:see_more_link) ,
      { :url => group_wiki_path(@group, @wiki) },
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
    'image_popup-%s' % wiki.id
  end  

  def wiki_body_id(wiki)
    'wiki_body-%s' % wiki.id
  end

  def wiki_toolbar_id(wiki)
    'markdown_toolbar-%s' % wiki.id
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
  #def create_wiki_toolbar(wiki)
  #  body_id = wiki_body_id(wiki)
  #  toolbar_id = wiki_toolbar_id(wiki)
  #  image_popup_code = modalbox_function(image_popup_show_url(wiki), :title => I18n.t(:insert_image))#

#    "wikiEditAddToolbar('#{body_id}', '#{toolbar_id}', '#{wiki.id.to_s}', function() {#{image_popup_code}});"
#  end

end


