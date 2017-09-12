class Group::EventsController < Group::BaseController
  # permissions 'events'
  include_controllers 'common/events'

  def index
    @events = Event.all
    render template: 'common/events/index'
  end
end
