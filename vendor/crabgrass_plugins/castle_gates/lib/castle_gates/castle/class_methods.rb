#
# Class Methods for Castles
#

module CastleGates
module Castle
module ClassMethods

  #
  # Used in subqueries.
  # Returns a select statement for castle_ids.
  # Will find castles where the holder has access to particular gates.
  #
  # UPGRADE: Later rails versions than 3.0 make subqueries on
  # Castle.where(:id => CastleGates::Key.for_holder(...))
  # so this probably can be simplified
  #
  def subselect_for_holder_and_gates(holder, gate_names)
    gate_names = [gate_names] unless gate_names.is_a? Array
    bits = gate_set.bits(gate_names)
    Key.for_holder(holder).
      with_gate_bits(bits).
      where(:castle_type => self.base_class.sti_name).
      select(:castle_id).
      to_sql
  end

   #
   # Used to find castles that with particular access. Assumes 'keys' table is joined in.
   #
   def conditions_for_gates(gate_names)
     gate_names = [gate_names] unless gate_names.is_a? Array
     bits = gate_set.bits(gate_names)
     "(#{bits} & ~castle_gates_keys.gate_bitfield) = 0"
   end


  ##
  ## GATES
  ##

  #
  # Adds a new gate to this castle
  #
  def gate(*args)
    gate_set.add( Gate.new(*args) )
  end

  def gate_set
    @gate_set ||= begin
      if superclass.respond_to?(:gate_set)
        superclass.gate_set
      else
        GateSet.new
      end
    end
  end

  def gates
    gate_set.values
  end

  ##
  ## CACHE
  ## This is implemented here, so that different instances with the same ID will share cache.
  ##

  def clear_key_cache
    @key_cache = {}
    @gate_bitfield_cache = {}
  end

  def key_cache
    @key_cache ||= {}
  end

  def gate_bitfield_cache
    @gate_bitfield_cache ||= {}
  end

end
end
end
