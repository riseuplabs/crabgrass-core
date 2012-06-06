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
        bug.function remote_function({:url => wiki_path(wiki, :preview => true), :method => :get})
        bug.selected @wiki == wiki
        bug.show_tab dom_id(wiki, :tab)
        bug.class "btn-mini"
      end
    end
  end

  def wiki_new_toggle(bug, wiki_type)
    priv = (wiki_type == :private_group_wiki)
    key = ('create_' + wiki_type.to_s).to_sym
    bug.label key.t
    bug.function remote_function({:url => new_group_wiki_path(@group, :private => priv), :method => :get})
    bug.icon 'plus'
  end

  def wiki_with_tabs(wiki)
    if wiki
      render :partial => '/groups/home/wiki', :locals => {
        :open => @wiki && (@wiki == wiki),
        :preview => !coming_from_wiki?(wiki),
        :wiki => wiki
      }
    else
      # TODO: make sure this is not rendered twice!
      render :text => '<div id="new_wiki"></div>'
    end
  end
end
