#
# object_id is reserved. so we are renaming.
#
# also, I am removing the index. I don't think it is used.
#
class RenamePageHistoryObjectToItem < ActiveRecord::Migration
  def self.up
    remove_index :page_histories, :column => [:object_id, :object_type]
    rename_column :page_histories, :object_id, :item_id
    rename_column :page_histories, :object_type, :item_type
  end

  def self.down
    rename_column :page_histories, :item_id, :object_id
    rename_column :page_histories, :item_type, :object_type
    add_index :page_histories, [:object_id, :object_type]
  end
end
