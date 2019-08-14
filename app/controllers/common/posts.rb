#
# Controllers that include this must define:
#
# Paths:
#
#   edit_post_path(post, *args)  -- path for editing post.
#        post_path(post, *args)  -- path for updating the post.
#             posts_path(*args)  -- path to create a post.
#
#
#
module Common::Posts
  def edit
    authorize @post
    render template: 'common/posts/edit'
  end

  def update
    authorize @post
    if params[:destroy]
      destroy
    else
      @post.update_attribute('body', params[:post][:body]) if params[:save]
      redirect_to action: :show
    end
  end

  def destroy
    authorize @post
    if @post.user != current_user
      Rails.logger.info "Page admin removed comment from '#{@post.user.login}' - maybe SPAM."
    end
    @post.destroy
    respond_to do |format|
      format.js { render template: 'common/posts/destroy' }
      format.html { redirect_to parent_redirect }
    end
  end

  protected

  def parent_redirect
    if @page.present?
      page_url(@page)
    else
      {action: :index}
    end
  end

end
