module Groups::WikisHelper

  # The group wiki specific functions live here.
  # The more generic ones live in
  # app/helpers/wikis/base_helper.rb

  def private_wiki_toggle
    wiki_toggle @group.private_wiki, :private_group_wiki
  end

  def public_wiki_toggle
    wiki_toggle @group.public_wiki, :public_group_wiki
  end

  def wiki_toggle(wiki, wiki_type)
    return wiki_new_link(wiki_type) if wiki.nil? or wiki.new_record?

    open = @wiki && (@wiki == wiki)

    link_to_toggle wiki_type.t, dom_id(wiki, :wrap),
      :onvisible => wiki_remote_function(wiki, wiki_type),
      :open => open,
      :class => 'section_toggle' do
      # show full wiki if we just focussed on this wiki:
      preview = !coming_from_wiki?(@wiki)
      render :partial => '/groups/home/wiki',
        :locals => {:preview => preview, :open => open, :wiki => wiki}
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

end
