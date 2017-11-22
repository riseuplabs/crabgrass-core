class CreatePgpKeys < ActiveRecord::Migration
  def change
    create_table :pgp_keys do |t|
      t.text :key
      t.string :fingerprint
      t.integer :user_id
      t.datetime :expires

      t.timestamps null: false
    end
  end
end
