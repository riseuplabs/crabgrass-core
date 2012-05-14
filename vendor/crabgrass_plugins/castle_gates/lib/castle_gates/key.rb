#
#
# schema:
#
#   create_table :keys do |p|
#     p.integer :castle_id
#     p.string  :castle_type
#     p.integer :holder_code
#     p.integer :gate_bitfield, :default => 0
#   end
#
# About gate_bitfield:
#
# The gate_bitfield of a key always has the first bit turned on. Why?
# This allows us to quickly identify the difference between a set of keys
# with no access and a query that returned zero keys. This distinction is
# important for handling gate defaults.
#
#
module CastleGates
  class Key < ActiveRecord::Base
    belongs_to :castle, :polymorphic => true

    named_scope :for_holder, lambda { |holder|
      { :conditions => conditions_for_holder(holder) }
    }

    #
    # Returns the gate_bitfield for a set of keys (defined by the named scope, not
    # an array of actual key objects).
    #
    # This is not a method of the keys association because of how we do caching.
    #
    def self.gate_bitfield(keys_named_scope)
      if ActiveRecord::Base.connection.adapter_name == 'SQLite'
        bitfield = keys_named_scope.all.inject(0) {|prior, key| prior | key.gate_bitfield}
      else
        bitfield = keys_named_scope.calculate(:bit_or, :gate_bitfield)
      end
      if bitfield == 0
        nil # no actual keys, so return nil
      else
        bitfield
      end
    end

    #
    # makes this key able to open these gates
    #
    # by default, the first bit is set. see note above.
    #
    def add_gates!(gates)
      self.gate_bitfield |= (1 | bits_for_gates(gates))
      save!
      self
    end

    #
    # sets the key to only open the specified list of gates,
    # destroying any prior grants.
    #
    # the first bit is always set. see note above.
    #
    def set_gates!(gates)
      self.gate_bitfield = 1
      add_gates!(gates)
    end

    #
    # revoke access for the specified keys
    #
    def remove_gates!(gates)
      self.gate_bitfield &= ~ bits_for_gates(gates)
      save!
      self
    end

    #
    # display the gate_bitfield in binary
    #
    def inspect
      "#<Key id:#{id}, castle_id:#{castle_id}, castle_type:#{castle_type}, holder_code:#{holder_code}, gate_bitfield:#{gate_bitfield.to_s(2)}>"
    end

    def self.conditions_for_holder(holder)
      conditions_for_holder_codes(Holder.all_codes_for_holder(holder))
    end

    private

    def self.conditions_for_holder_codes(codes)
      if codes.length == 1
        if codes.first.any?
          ["keys.holder_code = ?", codes.first]
        else
          "keys.holder_code IS NULL"
        end
      else
        ["keys.holder_code IN (?)", codes]
      end
    end

    #
    # Returns the bitmask for a set of gate names.
    #
    def bits_for_gates(gate_names)
      castle.gate_set.bits(gate_names)
    end

  end
end
