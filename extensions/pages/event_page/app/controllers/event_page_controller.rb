class EventPageController < Pages::BaseController
  before_filter :fetch_event
  permissions 'event_page'

  def show
  end

  def edit
  end

  def update
  end


  protected

  def fetch_event
    @event = @page.event if @page
  end

end
