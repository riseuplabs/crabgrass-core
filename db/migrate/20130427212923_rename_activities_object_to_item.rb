#
# object_id is reserved. so we are renaming.
#
class RenameActivitiesObjectToItem < ActiveRecord::Migration
  def self.up
    rename_column :activities, :object_id, :item_id
    rename_column :activities, :object_type, :item_type
    rename_column :activities, :object_name, :item_name
  end

  def self.down
    rename_column :activities, :item_id, :object_id
    rename_column :activities, :item_type, :object_type
    rename_column :activities, :item_name, :object_name
  end
end
