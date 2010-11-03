class InstallActsAsPermissive < ActiveRecord::Migration
  def self.up
    create_table :permissions do |p|
      p.integer :mask, :default => 0
      p.integer :object_id
      p.string :object_type
      p.integer :entity_code
    end

    add_index :permissions, [:object_id, :object_type, :entity_code]

  end

  def self.down
    drop_table :permissions
  end
end
