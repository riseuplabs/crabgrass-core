module Groups::WikiHelper

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
    link_to_remote I18n.t(:edit),
      { :url => edit_group_wiki_path(@group, @wiki)
     #  :with => "'height=' + (event.layerY? event.layerY : event.offsetY)"
      },
      :icon => 'pencil'

  end

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


end


