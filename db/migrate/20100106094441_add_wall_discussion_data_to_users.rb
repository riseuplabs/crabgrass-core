class AddWallDiscussionDataToUsers < ActiveRecord::Migration
  def self.up
    already_done = Discussion.where(commentable_type: 'User')
    done_ids = already_done.select(:commentable_id).map(&:commentable_id)
    puts "already have #{done_ids.size} wall discussions"
    Discussion.connection.execute <<-EOSQL
      INSERT INTO discussions (commentable_type, commentable_id)
        SELECT "User", users.id FROM users
          WHERE users.id NOT IN (#{done_ids.join(',')})
    EOSQL
    puts "Added #{already_done.count - done_ids.size} wall discussions"
  end

  def self.down
    Discussions.where(commentable_type: 'User').destroy_all
  end
end
