class EventPageController < Page::BaseController
  before_filter :fetch_event

  def show; end

  def edit; end

  def update
    @event.update_attributes params[:event]
    success if @event.valid?
    redirect_to page_url(@page, action: 'edit')
  end

  protected

  def fetch_event
    @event = @page.event if @page
  end
end
