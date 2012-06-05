module Groups::WikisHelper

  # The group wiki specific functions live here.
  # The more generic ones live in
  # app/helpers/wikis/base_helper.rb

  def wiki_toggles
    toggle_bug_links(private_wiki_toggle, public_wiki_toggle)
  end

  def private_wiki_toggle
    wiki_toggle @group.private_wiki, :private_group_wiki
  end

  def public_wiki_toggle
    wiki_toggle @group.public_wiki, :public_group_wiki
  end

  def wiki_toggle(wiki, wiki_type)
    return wiki_new_toggle(wiki_type) if wiki.nil? or wiki.new_record?
    { :label => wiki_type.t,
      :remote => group_wiki_path(@group, wiki, :preview => true),
      :method => :get
    }
  end

  def wiki_new_toggle(wiki_type)
    priv = (wiki_type == :private_group_wiki)
    key = ('create_' + wiki_type.to_s).to_sym
    { :label => key.t,
      :remote => new_group_wiki_path(@group, :private => priv),
      :icon => 'plus'
    }
  end

  def wiki_with_tabs(wiki)
    return unless wiki
    render :partial => '/groups/home/wiki', :locals => {
      :open => @wiki && (@wiki == wiki),
      :preview => !coming_from_wiki?(wiki),
      :wiki => wiki
    }
  end
end
