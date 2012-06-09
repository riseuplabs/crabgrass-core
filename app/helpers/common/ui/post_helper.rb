module Common::Ui::PostHelper

  def created_modified_date(created, modified=nil)
    return friendly_date(created) unless modified and (modified > created + 30.minutes)
    created_date = friendly_date(created)
    modified_date = friendly_date(modified)
    detail_string = "created:&nbsp;#{created_date}<br/>modified:&nbsp;#{modified_date}"
    link_to_function created_date, %Q[this.replace("#{detail_string}")], :class => 'dotted'
  end

  def edit_post_link(post)
    if may_edit_post?(post)
      link_to_remote :edit.t, {:url => edit_post_path(post), :method => 'get'}, {:class => 'shy', :icon => 'pencil'}
    end
  end

#  def edit_post_action(post)
#    return unless may_edit_posts?(post)
#    content_tag :div, :class=>'post_action_icon' do
#      link_to_remote_icon('pencil', {:url => {:controller => '/posts', :action => 'edit', :id => post.id}})
#    end
#  end

#  def star_post_action(post)
#    return unless may_twinkle_posts?(post)
#    content_tag :div, :class=>'post_action_icon' do
#      if !post.starred_by?(current_user)
#        link_to_remote_icon('star_plus', :url=>{:controller=>'posts', :action=>'twinkle', :id=>post.id})
#      else
#        link_to_remote_icon('star_minus', :url=>{:controller=>'posts', :action=>'untwinkle', :id=>post.id})
#      end
#    end
#  end

end
