#
# this replaces the prior 'install acts_as_locked'
#
class InstallCastleGates < ActiveRecord::Migration
  def self.up
    drop_table :keys
    create_table :keys do |p|
      p.integer :castle_id
      p.string  :castle_type
      p.integer :holder_code
      p.integer :gate_bitfield, default: 1
    end
    add_index :keys, %i[castle_id castle_type holder_code]
  end

  def self.down
    drop_table :keys
    create_table :keys do |p|
      p.integer :mask, default: 0
      p.integer :locked_id
      p.string :locked_type
      p.integer :keyring_code
    end
    add_index :keys, %i[locked_id locked_type keyring_code]
  end
end
