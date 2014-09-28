class Tracking::PageObserver < ActiveRecord::Observer
  observe :page

  def after_create(page)
    PageHistory::PageCreated.create(user: User.current, page: page)
  end

  def after_update(page)
    params = { user: User.current, page: page}
    PageHistory::ChangeTitle.create(params)  if page.title_changed?
    PageHistory::Deleted.create(params)      if page.deleted?
    PageHistory::MakePrivate.create(params)  if page.marked_as_private?
    PageHistory::MakePublic.create(params)   if page.marked_as_public?
  end

end
