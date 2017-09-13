class SetPollAndVoteTypes < ActiveRecord::Migration
  def self.up
    update_poll_type('RankingPoll', 'RankedVotePage')
    update_vote_type('RankingVote', 'RankingPoll')
    update_poll_type('RatingPoll', 'RateManyPage')
    update_vote_type('RatingVote', 'RatingPoll')
  end

  def self.down
    Poll.update_all('type = NULL')
    Vote.update_all('type = NULL')
  end

  protected

  def self.update_poll_type(poll_type, page_type)
    sql = <<-EOSQL
      UPDATE polls,pages
        SET polls.type="#{poll_type}"
        WHERE polls.id=pages.data_id
          AND polls.type IS NULL
          AND pages.data_type="Poll"
          AND pages.type="#{page_type}"
    EOSQL
    Poll.connection.execute sql
  end

  def self.update_vote_type(vote_type, poll_type)
    sql = <<-EOSQL
      UPDATE polls,votes
        SET votes.type="#{vote_type}"
        WHERE polls.id=votes.votable_id
          AND votes.type IS NULL
          AND ( votes.votable_type="Poll" OR votes.votable_type IS NULL )
          AND polls.type="#{poll_type}"
    EOSQL
    Vote.connection.execute sql
  end
end
