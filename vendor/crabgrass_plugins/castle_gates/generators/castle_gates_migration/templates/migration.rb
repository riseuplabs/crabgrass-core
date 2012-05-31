class InstallCastleGates < ActiveRecord::Migration
  def self.up
    create_table :keys do |p|
      p.integer :castle_id
      p.string  :castle_type
      p.integer :holder_code
      p.integer :gate_bitfield, :default => 1
    end
    add_index :keys, [:castle_id, :castle_type, :holder_code]
  end

  def self.down
    drop_table :keys
  end
end
