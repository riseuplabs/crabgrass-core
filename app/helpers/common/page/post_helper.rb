module Common::Page::PostHelper

  protected

  #
  # klass should be 'first' or 'last'
  #
  def post_pagination_links(posts, klass)
    if posts.any? && posts.respond_to?(:total_pages)
      if @page
        param_name = 'posts'
      else
        param_name = 'page'
      end
      will_paginate(posts, :class => "pagination p #{klass}", :param_name => param_name, :renderer => LinkRenderer::Page, :previous_label => :pagination_previous.t, :next_label => :pagination_next.t)
    end
  end


end

