class IndexUserParticipation < ActiveRecord::Migration
  def self.up
    add_index 'user_participations', %w[user_id changed_at], name: 'recent_changes'
  end

  def self.down
    remove_index 'user_participations', name: 'recent_changes'
  end
end
