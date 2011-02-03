module Page::PostHelper

  protected

  # for now, no ajax pagination, even in responses from ajax requests. 
  def post_pagination_links(posts)
    if posts.any? and posts.is_a?(WillPaginate::Collection)
      color = cycle('shade_odd', 'shade_even')
      content_tag(:tr, :class => color) do
        content_tag(:td, :colspan => 2) do
          will_paginate(posts, :param_name => 'posts', :renderer => LinkRenderer::Page, :previous_label => :pagination_previous.t, :next_label => :pagination_next.t)
        end
      end
    end
  end


end

