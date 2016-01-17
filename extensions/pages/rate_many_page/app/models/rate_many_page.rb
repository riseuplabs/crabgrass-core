class RateManyPage < Page

  before_validation :create_poll

  def body_terms
    return "" unless poll and poll.possibles
    poll.possibles.collect { |pos| "#{pos.name}\t#{pos.description}" }.join "\n"
  end

  alias_method :poll, :data

  protected

  #
  # create the RatingPoll object if it does not already exist
  #
  def create_poll
    unless self.data_id
      self.data = Poll::RatingPoll.new
    end
    return true # ensure we don't halt on this callback
  end

end
