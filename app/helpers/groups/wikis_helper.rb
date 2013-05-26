module Groups::WikisHelper

  def edit_mode_button(edit_mode)
    spinner('edit_mode') + ' ' +
    link_to(
      :edit_wiki.t,
      group_wikis_path(
        @group,
        :edit_mode => (edit_mode ? "off" : "on")
      ),
      :remote => true,
      :class => ['btn', ('active wiki_away' if edit_mode)].join(' '),
      :id => 'edit_mode_button'
    )
  end

  #
  # profile: [private|public]
  #
  def create_group_wiki_link(profile)
    link_to_remote :create_thing.t(:thing => :group_wiki.t),
      {:url => group_wikis_path(@group, :profile => profile), :method => :post},
      {:icon => 'plus'}
  end

end
