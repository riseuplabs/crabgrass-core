class Tracking::PostObserver < ActiveRecord::Observer
  observe :post

  def after_create(post)
    return unless post.try(:discussion)
    PageHistory::AddComment.create params_for_post(post)
  end

  def after_update(post)
    return unless post.body_changed? && post.try(:discussion)
    PageHistory::UpdateComment.create params_for_post(post)
  end

  def after_destroy(post)
    return unless post.try(:discussion)
    PageHistory::DestroyComment.create params_for_post(post)
  end

  protected
  def params_for_post(post)
    { user: User.current, page: post.discussion.page, item: post }
  end
end
