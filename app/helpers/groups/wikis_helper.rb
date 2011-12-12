module Groups::WikisHelper

  def private_wiki_toggle
    wiki_toggle @group.private_wiki, :private_group_wiki
  end

  def public_wiki_toggle
    wiki_toggle @group.public_wiki, :public_group_wiki
  end

  def wiki_toggle(wiki, wiki_type)
    return wiki_new_link(wiki_type) if wiki.nil? or wiki.new_record?

    open = @wiki && (@wiki == wiki)

    link_to_toggle wiki_type.t, dom_id(wiki),
      :onvisible => wiki_remote_function(wiki, wiki_type),
      :class => 'section_toggle',
      :open => open do
      if open
        # show full wiki if we just focussed on this wiki:
        preview = !coming_from_wiki?(@wiki)
        render :partial => 'common/wiki/show', :locals => {:preview => preview}
      end
    end
  end

  def wiki_new_link(wiki_type)
    priv = (wiki_type == :private_group_wiki)
    key = ('create_' + wiki_type.to_s).to_sym
    link_to key.t, new_group_wiki_path(@group, :private => priv),
      :icon => 'plus'
  end

  def wiki_remote_function(wiki, wiki_type)
    remote_function :url => group_wiki_path(@group, wiki, :preview => true),
      :before => show_spinner(wiki),
      :method => :get
  end

  def wiki_edit_link
    return unless may_edit_group_wiki?(@group)
    link_to :edit.t, edit_group_wiki_path(@group, @wiki),
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
    link_to :versions.t, wiki_versions_path(@wiki)
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

  #moved a bunch of methods to app/helpers/wikis/base_helper.rb

end


