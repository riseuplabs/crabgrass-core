class CreateEventPageController < Pages::CreateController

  permissions :pages, :object => 'page'

  protected

  def page_class
    EventPage
  end

end

