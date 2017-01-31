module Page::PostHelper

  protected

  ##
  ## POST PATHS
  ##

  #
  # Define the path for editing posts. This is used by all the post templates.
  #

  def edit_post_path(post, *args)
    edit_page_post_path(@page || post.discussion.page, post, *args)
  end

  def post_path(post, *args)
    page_post_path(@page || post.discussion.page, post, *args)
  end

  def posts_path(*args)
    page_posts_path(@page, *args)
  end

end
