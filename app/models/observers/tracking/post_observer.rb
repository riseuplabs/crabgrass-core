class PageTrackingObserver < ActiveRecord::Observer
  observe :post

  def after_create(post)
    return unless User.current
    return unless post.try(:discussion) && post.discussion.page
    PageHistory::AddComment.create!(:user => User.current, :page => post.discussion.page, :object => post)
  end

  def after_update(post)
    return unless post.body_changed?
    return unless User.current
    return unless post.try(:discussion) && post.discussion.page
    PageHistory::UpdateComment.create!(:user => User.current, :page => post.discussion.page, :object => post)
  end

  def after_destroy(post)
    return unless User.current
    if post.try(:discussion) and post.discussion.page
      PageHistory::DestroyComment.create!(:user => User.current, :page => post.discussion.page, :object => post)
    end
  end

end
