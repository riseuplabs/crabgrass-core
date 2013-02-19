class Tracking::WikiObserver < ActiveRecord::Observers
  observe :wiki

  def after_update(wiki)
    return unless User.current && wiki.body_changed?
    PageHistory::UpdatedContent.create(:user => User.current, :page => Page.find(:first, :conditions => {:data_type => "Wiki", :data_id => wiki.id}))
  end
end
