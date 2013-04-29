class AssignPollsToVotes < ActiveRecord::Migration

  def self.up
    Possible.connection.execute <<-EOSQL
      UPDATE votes, possibles
        SET votes.votable_type = 'Poll', votes.votable_id = possible.poll_id
        WHERE votes.possible_id = possible.id
    EOSQL
  end

  def self.down
    Vote.update_all('votable_id = NULL')
    Vote.update_all('votable_type = NULL')
  end
end
