module Groups::WikisHelper

  # The group wiki specific functions live here.
  # The more generic ones live in
  # app/helpers/wikis/base_helper.rb

  def wiki_toggles
    formy(:toggle_bugs) do |f|
      private_wiki_toggle(f)
      public_wiki_toggle(f)
    end
  end

  def private_wiki_toggle(f)
    wiki_toggle f, @group.private_wiki, :private_group_wiki
  end

  def public_wiki_toggle(f)
    wiki_toggle f, @group.public_wiki, :public_group_wiki
  end

  def wiki_toggle(f, wiki, wiki_type)
    f.bug do |bug|
      if wiki.nil? or wiki.new_record?
        wiki_new_toggle(bug, wiki_type)
      else
        bug.label wiki_type.t
        bug.function load_wiki_tab_function(wiki)
        bug.selected @wiki == wiki
        bug.show_tab dom_id(wiki, :tab)
        bug.class "btn-mini"
      end
    end
  end

  def load_wiki_tab_function(wiki)
    url = wiki_path(wiki, :preview => true)
    clear_wiki = get_dom_element(wiki) + ".update();"
    wiki_tab = get_dom_element(wiki, :tab)
    tab_link = wiki_tab + ".down('li.first a')"
    tab_remote_function({:url => url, :loading => clear_wiki}, tab_link);
  end

  def wiki_new_toggle(bug, wiki_type)
    priv = (wiki_type == :private_group_wiki)
    key = ('create_' + wiki_type.to_s).to_sym
    bug.label key.t
    bug.function remote_function({:url => new_group_wiki_path(@group, :private => priv), :method => :get})
    bug.icon 'plus'
    bug.show_tab 'new_wiki'
    bug.class 'btn-mini'
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
