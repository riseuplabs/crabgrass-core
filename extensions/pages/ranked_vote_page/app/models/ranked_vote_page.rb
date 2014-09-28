class RankedVotePage < Page
  before_validation :create_poll

  # Return string of all poll possibilities, for the full text search index
  def body_terms
    return "" unless poll and poll.possibles
    poll.possibles.collect { |pos| "#{pos.name}\t#{pos.description}" }.join "\n"
  end

  alias_method :poll, :data
  protected

  #
  # create the RankingPoll object if it does not already exist
  #
  def create_poll
    unless self.data_id
      self.data = RankingPoll.new
    end
    return true # ensure we don't halt on this callback
  end

end

