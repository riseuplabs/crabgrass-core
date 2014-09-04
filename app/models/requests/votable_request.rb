#
# parent class for votable requests
#
# subclasses must define the methods:
#
#   voting_population_count() -- return the number of people who may potentially vote on this request.
#
# request passes if one of the following is true:
#
# (a) first n votes are all 'yes' (where n = quick_approval_threshold)
# (b) yes votes outnumber no votes within vote_duration
#

class VotableRequest < Request

  #
  # returns Requests for which the voting time has passed
  #
  # use lamba here so that VOTE_DURATION.ago is evaluated freshly each time
  scope :voting_completed, lambda {
    where("state = 'pending' AND created_at <= ?", self.vote_duration.ago)
  }

  #
  # the default duration for votable requests
  #
  def self.vote_duration
    1.month
  end

  def votable?
    true
  end

  #
  # this creates a nice blending function for quick approval, starting at 50%
  # and asymptotically reaching 5% as the population gets very large.
  #
  # for example:
  #
  #   users:   4    5   10   100   1000
  # percent:  50%  40%  30%   10%     5%
  #
  def self.quick_approval_threshold(population)
    x = population
    percent = 500.0/(x+10) + 5
    return (x*percent/100).ceil
  end

  def approve_by!(user)
    if may_approve?(user)
      if instant_approval(user)
        set_state('appoved')
      else
        add_vote!('approve', user)
        tally!
      end
    else
      raise PermissionDenied.new
    end
  end

  def reject_by!(user)
    if may_approve?(user)
      add_vote!('reject', user)
      tally!
    else
      raise PermissionDenied.new
    end
  end

  #
  # we don't want to let people destroy votable requests, because you could
  # game the system by creating and destroying requests.
  #
  def may_destroy?(user)
    false
  end

  #
  # State changes are always allowed, because they are only triggered by
  # tally!() for VotableRequests.
  #
  def approval_allowed()
    true
  end

  #
  # tally up the votes and update state for the request
  #
  def tally!
    yes_votes  = votes.approved.count
    no_votes   = votes.rejected.count
    population = voting_population_count

    if voting_period_active
      if no_votes == 0 and yes_votes >= self.class.quick_approval_threshold(population)
        new_state = 'approved'
      elsif no_votes >= (population * 0.5)
        new_state = 'rejected'
      elsif yes_votes > (population * 0.5)
        new_state = 'approved'
      else
        new_state = nil
      end
    elsif voting_period_over
      if no_votes == 0
        new_state = 'approved'
      elsif yes_votes > no_votes
        new_state = 'approved'
      else
        new_state = 'rejected'
      end
    end

    set_state!(new_state) if new_state
  end

  protected

  #
  # To be called periodically by cron in order to approve requests
  # that have reached the end of their voting period.
  #
  def self.tally_votes!
    tally_requests = self.voting_completed
    tally_requests.each do |request|
      request.tally!
    end
  end

  def voting_period_over
    created_at <= self.class.vote_duration.ago
  end

  def voting_period_active
    created_at > self.class.vote_duration.ago
  end

  def voting_population_count()
    raise 'subclass does not define voting_population_count()'
  end

  #
  # some users may be able to cut short the voting.
  # for example, if the vote is to expell a user and the user votes 'yes'
  #
  def instant_approval(user)
    false
  end

end
