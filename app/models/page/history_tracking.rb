module Page::HistoryTracking
  extend ActiveSupport::Concern

  included do
    has_many :page_histories,
      class_name: 'Page::History',
      dependent: :delete_all,
      order: "page_histories.id desc"
  end

  def marked_as_public?
    self.public_changed? && self.public == true
  end

  def marked_as_private?
    self.public_changed? && self.public == false
  end
end
