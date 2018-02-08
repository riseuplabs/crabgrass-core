module Common::Ui::PostHelper
  def created_date(created, _modified = nil, href = nil)
    created_date = friendly_date(created)
    link_to_function created_date,
                     'var parent = this.up("div");
                      parent.toggleClassName("hide");
                      parent.siblings().last().toggleClassName("hide")',
                     href: href, class: 'dotted'
  end

  def created_modified_date(created, modified = nil, href = nil)
    return created_date(created, modified, href) unless modified and (modified > created + 30.minutes)
    created_date = friendly_date(created)
    modified_date = friendly_date(modified)
    detail_string = "created:&nbsp;#{created_date}<br>modified:&nbsp;#{modified_date}"

    link_to_function detail_string.html_safe,
                     'var parent = this.up("div");
                      parent.toggleClassName("hide");
                      parent.siblings().last().toggleClassName("hide")',
                     href: href, class: 'dotted'
  end

  #
  # display the edit link for this post.
  # sometimes, posts are not really posts. in this case, we skip the edit link.
  #
  def edit_post_link(post)
    if post.is_a?(Post) && may_edit_post?(post)
      link_to :edit.t, edit_post_path(post),
        remote: true,
        method: 'get',
        class: 'shy',
        icon: 'pencil'
    end
  end

  def star_post_action(post)
    return unless may_twinkle_posts?(post)
    if !post.starred_by?(current_user)
      link_to '', post_star_path(post), remote: true,
                                        class: 'small_icon_button shy',
                                        icon: 'star_plus',
                                        data: { toggle: { star_plus_16: :star_minus_16 } },
                                        method: :post
    else
      link_to '', post_star_path(post), remote: true,
                                        class: 'small_icon_button shy',
                                        icon: 'star_minus',
                                        data: { toggle: { star_minus_16: :star_plus_16 } },
                                        method: :delete
    end
  end
end
