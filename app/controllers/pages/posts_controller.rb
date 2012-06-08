class Pages::PostsController < ApplicationController

  permissions 'posts', 'pages'
  prepend_before_filter :fetch_data
  before_filter :login_required
  guard :may_ALIAS_page_post?
  guard :show => :may_show_page?

  # if something goes wrong with create, redirect to the page url.
  rescue_render :create => lambda {redirect_to(page_url(@page))}

  # do we still want this?...
  # cache_sweeper :social_activities_sweeper, :only => [:create, :save, :twinkle]

  def show
    redirect_to page_url(@post.discussion.page) + "#posts-#{@post.id}"
  end

  def create
    @post = Post.create! @page, current_user, @group, params[:post]
    current_user.updated(@page)
    respond_to do |wants|
      wants.html { redirect_to page_url(@page) }
      # maybe? :anchor => @page.discussion.posts.last.dom_id), :paging => params[:paging] || '1')
      wants.js { render :template => 'pages/posts/create' }
    end
  end

  def edit
  end

  def update
    if params[:save]
      @post.update_attribute('body', params[:post][:body])
    elsif params[:destroy]
      @post.destroy
      return(render :action => 'destroy')
    end
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
    @post = Post.find(params[:id], :include => :discussion) if params[:id]
    if @post
      if @post.discussion.page != @page
        raise PermissionDenied
      end
    end
  end

end

