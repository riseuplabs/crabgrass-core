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
    render template: 'common/posts/edit'
  end

  def update
    if params[:destroy]
      @post.destroy
    elsif params[:save]
        @post.update_attribute('body', params[:post][:body])
    end
    render template: 'common/posts/update'
  end

  #
  # destroy a request.
  # uses model permissions.
  #
  def destroy
    @request.destroy_by!(current_user)
    notice :thing_destroyed.tcap(thing: I18n.t(@request.name)), :later
    render template: 'common/posts/destroy'
  end

  protected

  def render_posts_refresh(posts)
    @post = Post.new # for the reply form
    render template: 'common/posts/refresh'
  end

end

