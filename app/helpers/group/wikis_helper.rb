module Group::WikisHelper
  def should_render_group_wiki?
    @private_wiki.present? || @public_wiki.present?
  end

  #
  # profile: [private|public]
  #
  def create_group_wiki_link(profile)
    link_to :create_thing.t(thing: :group_wiki.t)+' ('+(profile+'_wiki').to_sym.t+')',
            group_wikis_path(@group, profile: profile),
            method: :post, icon: :plus
  end

  def group_wiki_heading_or_toggles
    if @private_wiki.present? && @public_wiki.present?
      group_wiki_toggles
    else
      wiki = @private_wiki.present? ? @private_wiki : @public_wiki
      group_wiki_heading(wiki)
    end
  end

  def group_wiki_toggles
    formy(:toggle_bugs) do |f|
      f.bug do |b|
        b.label :private_wiki.t
        b.show_tab 'private_panel'
        b.selected true
      end
      f.bug do |b|
        b.label :public_wiki.t
        b.show_tab 'public_panel'
      end
    end
  end

  def group_wiki_heading(wiki)
    content_tag :h2, id: wiki.label, class: :first do
      I18n.t wiki.label
    end
  end
end
