class Pages::CreateEventController < Page::CreateController

  before_filter :set_page_class

  def set_page_class
    @page_class = EventPage
  end

end

