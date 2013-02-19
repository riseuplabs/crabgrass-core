class Tracking::PageObserver < ActiveRecord::Observer
  observe :page

  def after_create(page)
    if User.current
      PageHistory::PageCreated.create!(:user => User.current, :page => page)
    end
  end

  def after_update(page)
    if User.current
      PageHistory::ChangeTitle.create!(:user => User.current, :page => page)  if page.title_changed?
      PageHistory::Deleted.create!(:user => User.current, :page => page)      if page.deleted?
      PageHistory::MakePrivate.create!(:user => User.current, :page => page)  if page.marked_as_private?
      PageHistory::MakePublic.create!(:user => User.current, :page => page)   if page.marked_as_public?
    end
  end

end
