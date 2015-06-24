module Common::Ui::PostHelper

  def created_modified_date(created, modified=nil)
    return friendly_date(created) unless modified and (modified > created + 30.minutes)
    created_date = friendly_date(created)
    modified_date = friendly_date(modified)
    detail_string = "created:&nbsp;#{created_date}<br/>modified:&nbsp;#{modified_date}"
    link_to_function created_date, %Q[this.replace("#{detail_string}")], class: 'dotted'
  end

  #
  # display the edit link for this post.
  # sometimes, posts are not really posts. in this case, we skip the edit link.
  #
  def edit_post_link(post)
    if post.is_a?(Post) && may_edit_post?(post)
      link_to_remote :edit.t, {url: edit_post_path(post), method: 'get'}, {class: 'shy', icon: 'pencil'}
    end
  end

  def star_post_action(post)
    return unless may_twinkle_posts?(post)
    content_tag :div, :class=>'shy' do
      if !post.starred_by?(current_user)
        link_to '', post_star_path(post), remote: true,
          class: 'small_icon_button',
          icon: 'star_plus',
          method: :post
      else
        link_to '', post_star_path(post), remote: true,
          class: 'small_icon_button',
          icon: 'star_minus',
          method: :delete
      end
    end
  end

end
