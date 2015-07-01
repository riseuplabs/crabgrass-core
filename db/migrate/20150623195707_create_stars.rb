class CreateStars < ActiveRecord::Migration
  def change
    create_table :stars do |t|
      t.integer :user_id, null: false
      t.integer :starred_id, null: false
      t.string :starred_type, null: false

      t.timestamps
    end
  end
end
