class ReplaceProfileAssetWithPicture < ActiveRecord::Migration
  def self.up
    asset_ids = Profile.connection.select_values('select photo_id from profiles');
    asset_ids.each do |id|
      Asset.destroy(id) if Asset.exists?(id)
    end
    remove_column :profiles, :photo_id
    add_column :profiles, :picture_id, :integer
  end

  def self.down
    add_column :profiles, :picture_id
    remove_column :profiles, :photo_id, :integer
  end
end
