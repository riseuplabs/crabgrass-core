class CreateEventPageController < Pages::CreateController

  guard_like 'page'

  protected

  def page_class
    EventPage
  end

end

