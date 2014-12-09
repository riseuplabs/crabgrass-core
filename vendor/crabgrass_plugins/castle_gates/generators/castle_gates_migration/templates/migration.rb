class InstallCastleGates < ActiveRecord::Migration
  def self.up
    create_table :castle_gates_keys do |p|
      p.integer :castle_id
      p.string  :castle_type
      p.integer :holder_code
      p.integer :gate_bitfield, default: 1
    end
    add_index :castle_gates_keys,
      [:castle_id, :castle_type, :holder_code],
      name: 'index_castle_gates_by_castle_and_holder_code'
  end

  def self.down
    drop_table :castle_gates_keys
  end
end
