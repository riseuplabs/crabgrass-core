module Widget::WikiHelper

  # used to mark private and public tabs
  def area_id(wiki)
    'edit_area-%s' % wiki.id
  end

  def wiki_edit_link(wiki_id=nil)
    return unless may_edit_wiki?(@group) #, wiki_id) #2nd paramater?
    # note: firefox uses layerY, ie uses offsetY
    link_to_remote('blah',#:edit.t,
                   {:url => wiki_action('edit', :wiki_id => wiki_id), :with => "'height=' + (event.layerY? event.layerY : event.offsetY)"},
                   {:icon => 'pencil'}
                   )
  end

  def wiki_action(action, hash={})
    {:controller => 'widget/wiki', :action => action, :group_id => @group.id, :profile_id => (@profile ? @profile.id : nil)}.merge(hash)
  end

  def wiki_more_link(wiki_id=nil)
    wiki=Wiki.find(wiki_id)
    return unless wiki.try.body and wiki.body.length > 500
    link_to_remote(:see_more_link.t,
                   {:url => wiki_action('show', :wiki_id => wiki_id)},
                   {:icon => 'plus'})
  end

  def wiki_less_link(wiki_id=nil)
    wiki=Wiki.find(wiki_id)
    return unless wiki.try.body and wiki.body.length > 500
    link_to_remote(:see_less_link.t,
                   {:url => wiki_action('teaser', :wiki_id => wiki_id)},
                   {:icon => 'minus'})
  end


end


