class InstallActsAsLocked < ActiveRecord::Migration
  def self.up
    create_table :keys do |p|
      p.integer :mask, :default => 0
      p.integer :locked_id
      p.string :locked_type
      p.integer :keyring_code
    end

    add_index :keys, [:locked_id, :locked_type, :keyring_code]

  end

  def self.down
    drop_table :keys
  end
end
