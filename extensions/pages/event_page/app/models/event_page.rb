class EventPage < Page #:nodoc:
  before_create :create_event

  def event
    data
  end

  # indexing hooks

  # def body_terms
  # description
  # end

  protected

  def create_event
    self.data = Event.create
  end
end
