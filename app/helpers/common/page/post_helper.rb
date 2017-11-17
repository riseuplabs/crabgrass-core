module Common::Page::PostHelper
  protected

  #
  # pagination links for posts. On pages, we call
  # the pagination param 'posts', but otherwise we call
  # it 'pages'.
  #
  def post_pagination_links(posts)
    if posts.any? && posts.respond_to?(:total_pages)
      param_name = if @page
                     'posts'
                   else
                     'page'
                   end
      content_tag :div do
        will_paginate(posts, class: 'pagination',
                             param_name: param_name,
                             renderer: LinkRenderer::Page,
                             previous_label: :pagination_previous.t,
                             next_label: :next.t)
      end
    end
  end
end
