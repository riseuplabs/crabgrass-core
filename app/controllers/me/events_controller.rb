class Me::EventsController < Me::BaseController

  #permissions 'events'
  include_controllers 'common/events'

  def index
    @events = Event.find(:all)
    render :template => 'common/events/index'
  end

end
