# This migration comes from acts_as_taggable_on_engine (originally 1)
class ActsAsTaggableOnMigration < ActiveRecord::Migration
  def self.up
    # Limit is created to prevent MySQL error on index
    # length for MyISAM table type: http://bit.ly/vgW2Ql
    change_column :taggings, :context, :string, limit: 128
  end

  def self.down
    change_column :taggings, :context, :string
  end
end
