class CreateNotices < ActiveRecord::Migration
  def self.up
    create_table :notices do |t|
      t.string :type
      t.integer :user_id
      t.integer :avatar_id
      t.text :data
      t.integer :noticable_id
      t.string :noticable_type
      t.boolean :dismissed
      t.datetime :dismissed_at
      t.timestamps
    end
    add_index "notices", "user_id"
  end

  def self.down
    drop_table :notices
  end
end
