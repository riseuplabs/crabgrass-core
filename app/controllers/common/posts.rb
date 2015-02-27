#
# Controllers that include this must define:
#
# Paths:
#
#   edit_post_path(post, *args)  -- path for editing post.
#        post_path(post, *args)  -- path for updating the post.
#             posts_path(*args)  -- path to create a post.
#
# Permissions:
#
#     may_create_post?()
#   may_edit_post?(post)
#
#
module Common::Posts

  def edit
    render(:update) do |page|
      page.replace(@post.body_id, partial: 'common/posts/default/edit', locals: {post: @post})
    end
  end

  def update
    if params[:destroy]
      @post.destroy
      render :update do |page|
        page.hide @post.dom_id
      end
    else
      if params[:save]
        @post.update_attribute('body', params[:post][:body])
      end
      render :update do |page|
        page.replace(@post.body_id, partial: 'common/posts/default/body', locals: {post: @post})
      end
    end
  end

  #
  # destroy a request.
  # uses model permissions.
  #
  def destroy
    @request.destroy_by!(current_user)
    notice :thing_destroyed.tcap(thing: I18n.t(@request.name)), :later
    render(:update) {|page| page.redirect_to requests_path}
  end

  protected

  def render_posts_refresh(posts)
    @post = Post.new # for the reply form
    render :update do |page|
      standard_update(page)
      page.replace('posts', partial: 'common/posts/list', locals: {posts: posts})
    end
  end

end

