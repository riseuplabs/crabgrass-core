class AddDiscussionIdIndexToRelationship < ActiveRecord::Migration

  # make it faster to fetch relationships for the discussions on me/messages
  def change
    add_index :relationships, :discussion_id
  end
end
