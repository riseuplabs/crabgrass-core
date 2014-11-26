class Pages::PostsController < ApplicationController

  include_controllers 'common/posts'

  permissions 'pages'
  permissions 'posts'
  helper 'pages/post'

  prepend_before_filter :fetch_data
  before_filter :login_required
  before_filter :authorization_required
  guard :may_ALIAS_post?
  guard show: :may_show_page?

  # if something goes wrong with create, redirect to the page url.
  rescue_render create: lambda { |controller| redirect_to(page_url(@page)) }

  # do we still want this?...
  # cache_sweeper :social_activities_sweeper, :only => [:create, :save, :twinkle]

  def show
    redirect_to page_url(@post.discussion.page) + "#posts-#{@post.id}"
  end

  def create
    @post = Post.create! @page, current_user, post_params
    current_user.updated(@page)
    @page.save
    # maybe? :anchor => @page.discussion.posts.last.dom_id), :paging => params[:paging] || '1')
    render_posts_refresh @page.posts(pagination_params)
  end

  #
  # I would like this to be in an add-on...
  #
  #  def twinkle
  #    if rating = @post.ratings.find_by_user_id(current_user.id)
  #      rating.update_attribute(:rating, 1)
  #    else
  #      rating = @post.ratings.create(:user_id => current_user.id, :rating => 1)
  #    end

  #    # this should be in an observer, but oddly it doesn't work there.
  #    TwinkledActivity.create!(
  #      :user => @post.user, :twinkler => current_user,
  #      :post => {:id => @post.id, :snippet => @post.body[0..30]}
  #    )
  #  end

  #  def untwinkle
  #    if rating = @post.ratings.find_by_user_id(current_user.id)
  #      rating.destroy
  #    end
  #  end

  protected

  def fetch_data
    @page = Page.find(params[:page_id])
    if params[:id]
      @post = @page.discussion.posts.find(params[:id], include: :discussion)
      raise PermissionDenied.new unless @post
    end
  end

  def post_params
    params.require(:post).permit(:body)
  end
end

