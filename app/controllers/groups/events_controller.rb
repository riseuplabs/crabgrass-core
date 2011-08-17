class Groups::EventsController < Groups::BaseController

  #permissions 'events'
  include_controllers 'common/events'

  def index
    @events = Event.find(:all)
    render :template => 'common/events/index'
  end

  protected

  # unlike other me controllers, we actually want to check
  # permissions for requests
  def authorized?
    true # check_permissions!
  end

end
