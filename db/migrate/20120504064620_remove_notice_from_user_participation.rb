class RemoveNoticeFromUserParticipation < ActiveRecord::Migration
  def self.up
    remove_column :user_participations, :inbox
    remove_column :user_participations, :notice
  end

  def self.down
    add_column :user_participations, :inbox, :boolean, default: false
    add_column :user_participations, :notice, :text
  end
end
