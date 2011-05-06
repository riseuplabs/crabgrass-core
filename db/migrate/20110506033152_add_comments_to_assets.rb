class AddCommentsToAssets < ActiveRecord::Migration
  def self.up
    add_column :assets, :user_id, :int, :limit => 11
    add_column :assets, :comment, :text
    add_column :asset_versions, :user_id, :int, :limit => 11
    add_column :asset_versions, :comment, :text
  end

  def self.down
    remove_column :assets, :user_id
    remove_column :assets, :comment
    remove_column :asset_versions, :user_id
    remove_column :asset_versions, :comment
  end
end


