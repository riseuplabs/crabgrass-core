module Pages::HistoryHelper
  def description_for(page_history)
    I18n.t page_history.description_key, page_history.description_params
  end

  def details_for(page_history)
    return '' if page_history.details_key.blank?
    I18n.t page_history.details_key, page_history.details
  end
end
