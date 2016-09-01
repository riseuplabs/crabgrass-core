class DropMenuItems < ActiveRecord::Migration
  def up
    drop_table :menu_items
  end

  def down
    create_table "menu_items" do |t|
      t.string   "title"
      t.string   "link"
      t.integer  "position"
      t.integer  "group_id"
      t.boolean  "default"
    end
  end
end
