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
    authorize @post, :edit?
    render template: 'common/posts/edit'
  end

  def update
    authorize @post, :edit?
    @post.update_attribute('body', params[:post][:body]) if params[:save]
    redirect_to action: :show
  end

  def destroy
    authorize @post, :edit?
    @post.destroy
    render template: 'common/posts/destroy'
  end

end
