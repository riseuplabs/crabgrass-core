module Page::HistoryTracking
  extend ActiveSupport::Concern

  included do
    has_many :page_histories,
             -> { order 'page_histories.id desc' },
             class_name: 'Page::History',
             dependent: :delete_all
  end

  def marked_as_public?
    public_previously_changed? && public == true
  end

  def marked_as_private?
    public_previously_changed? && public == false
  end
end
