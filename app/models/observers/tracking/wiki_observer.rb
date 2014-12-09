class Tracking::WikiObserver < ActiveRecord::Observer
  observe :wiki

  def after_update(wiki)
    return unless wiki.body_changed?
    page = Page.where(data_type: "Wiki", data_id: wiki).first
    PageHistory::UpdatedContent.create user: User.current, page: page
  end
end
