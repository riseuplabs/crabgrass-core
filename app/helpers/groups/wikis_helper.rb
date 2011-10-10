module Groups::WikisHelper

  # used to mark private and public tabs
  def area_id(wiki)
    'edit_area-%s' % wiki.id
  end

  def edit_wiki_link
    return unless may_edit_group_wiki?(@group)
    # TODO: was this used for section editing?
    # note: firefox uses layerY, ie uses offsetY
    link_to_remote :edit.t,
      { :url => edit_group_wiki_path(@group, @wiki),
        :method => :get
     #  :with => "'height=' + (event.layerY? event.layerY : event.offsetY)"
      },
      :icon => 'pencil'
  end

  def wiki_action(action, hash={}) #not clear if we actually want this
    {:controller => 'widget/wiki', :action => action, :group_id => @group.id, :profile_id => (@profile ? @profile.id : nil)}.merge(hash)
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

  #from extensions/pages/wiki_page/app/helpers/wiki_helper.rb
  def wiki_locked_notice(wiki)
    return if wiki.document_open_for? current_user

    error_text = I18n.t(:wiki_is_locked, :user => wiki.locker_of(:document).try.name || I18n.t(:unknown))
    %Q[<blockquote class="error">#{h error_text}</blockquote>]
  end

  #next 2 methods from extensions/pages/wiki_page/app/helpers/wiki_helper.rb
# maybe we dont' want them
  def image_popup_id(wiki)
    'image_popup-%s' % wiki.id
  end  

  def wiki_body_id(wiki)
    'wiki_body-%s' % wiki.id
  end



end


