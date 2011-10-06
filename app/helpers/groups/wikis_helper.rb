module Groups::WikisHelper

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


