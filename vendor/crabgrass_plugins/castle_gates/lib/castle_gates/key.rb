module CastleGates
  class Key < ActiveRecord::Base
    belongs_to :castle, :polymorphic => true

    named_scope :for_holder, lambda { |holder|
      { :conditions => access_conditions_for(holder) }
    }

    cattr_accessor :symbol_codes
    cattr_accessor :holder_klass
    cattr_accessor :holder_block

    # OLD
    def opens?(locks)
      castle.class.keys_open_locks?(self, locks)
    end

    # update! takes a hash with locks as keys.
    # all locks with true values can be opened
    # all locks with false values can not be opened
    # locks that are not specified are left untouched
    # returns an array of the locks set.
    # OLD
    def update!(locks_hash = {})
      # make sure we only have valid keys
      locks_hash.slice castle.class.locks_for_bits(~0)
      grants = locks_hash.map{|k,v|k if v == 'true'}.compact
      revokes = locks_hash.map{|k,v|k if v == 'false'}.compact
      self.grant! grants
      self.revoke! revokes
      return grants + revokes
    end

    #
    # makes this key able to open these gates
    #
    def add_gates!(gates)
      self.gate_bitfield |= bits_for_gates(gates)
      save!
      castle.after_key_update(self)
      self
    end

    #
    # sets the key to only open the specified list of gates,
    # destroying any prior grants
    #
    def set_gates!(gates)
      self.gate_bitfield = 0
      add_gates!(gates)
    end

    #
    # revoke access for the specified keys
    #
    def revoke_gates!(gates)
      self.gate_bitfield &= ~ bits_for_gates(gates)
      save!
      castle.after_key_update(self)
      self
    end

    # OLD
    def grant!(locks, options = {})
      if !options.nil? and options[:reset]
        self.gate_bitfield = bits_for_locks(locks)
      else
        self.gate_bitfield |= bits_for_locks(locks)
      end
      save
      if castle.respond_to? :grant_dependencies
        castle.grant_dependencies self
      end
      self
    end

    # OLD
    def revoke!(locks)
      self.gate_bitfield &= ~bits_for_locks(locks)
      save
      if castle.respond_to? :revoke_dependencies
        castle.revoke_dependencies self
      end
      self
    end

    # OLD
    def bits_for_locks(locks)
      castle.class.bits_for_locks(locks)
    end

    # OLD
    def allowed_for?(lock)
      castle.class.key_allowed?(lock, self.holder)
    end


    #
    # This is used in the {grant,revoke}_dependencies functions
    # and in the tests
    #
    # OLD
    def locks(options={})
      klass = castle.class
      postfix = klass.name.underscore
      current_locks = nil

      if options[:disabled]
        current_locks = klass.locks_for_bits(~self.gate_bitfield)
      else
        current_locks = klass.locks_for_bits(self.gate_bitfield)
      end

      if options[:with_class]
        current_locks.map{|l| (l.to_s + '_' + postfix).to_sym}
      elsif options[:select_options]
        current_locks.map{|l| [(l.to_s + '_' + postfix).to_sym, klass.bits_for_locks(l)]}
      else
        current_locks
      end
    end

    # OLD
    def locks=(new_locks)
      self.gate_bitfield |= bits_for_locks(new_locks)
    end

    # OLD
    def holder
      @holder ||= self.class.holder_for(self.holder_code)
    end

    # OLD
    def holder=(value)
      self.holder_code = self.class.code_for_holder(value)
    end

    #
    # returns true if +key_holder+ is the holder of this key
    #
    #def holder?(key_holder)
    #  self.holder_code == self.class.code_for_holder(key_holder).to_i
    #end

    #def self.code_for_holder(holder)
      #holder = holder.to_sym if holder.is_a? String
      #if holder.is_a? Symbol
      #  symbol_codes[holder] or
      #  raise LockError.new("ActsAsLocked: Entity alias '#{holder}' is unknown.")
      #else
      #  holder.holder_code
      #end
    #end

    def self.access_conditions_for(holder)
      if holder_name_array = holder.key_holders
        ["keys.holder_code IN (?)", Holder.list(holder_name_array)]
      elsif code = holder.code
        ["keys.holder_code = ?", code]
      else
        "keys.holder_code IS NULL"
      end
    end

    # OLD
    def self.holder_for(holder_code)
      if self.holder_klass
        self.holder_klass.find(holder_code)
      elsif !self.holder_block.nil?
        self.holder_block.call(holder_code)
      end
    end

    # There are two ways of using this...
    # if all holders are of one class and the code is the id use
    #   resolve_holder Klass
    # otherwise you need to specify a decoding function
    #   resolve_holder do ...
    #
    #def self.resolve_holder(klass = nil, &block)
    #  if block_given?
    #    self.holder_block = block
    #    self.holder_klass = nil
    #  elsif klass.is_a? Class
    #    self.holder_klass = klass
    #  elsif klass.is_a? Symbol or klass.is_a? String
    #    self.holder_klass = klass.to_s.capitalize.constantize
    #  end
    #end

    # OLD
    #def self.symbol_for(code)
    #  symbol_codes.detect{|k,v| v == code}.first
    #end

    private

    #
    # Returns the bitmask for a set of gate names.
    #
    def bits_for_gates(gate_names)
      castle.class.gate_set.select(gate_names).bits
    end

  end
end
