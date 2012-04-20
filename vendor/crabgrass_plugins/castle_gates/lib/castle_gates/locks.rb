module CastleGates
  module Locks

    def self.add_bits(class_name, locks)
      @@hash ||= {}
      class_hash = @@hash[class_name] ||= {}
      reject_existing_locks!(class_hash, locks)
      class_hash.merge! build_bit_hash(locks, @@hash[class_name].count)
    end

    def self.add_options(class_name, locks, options)
      @@options ||= {}
      class_options = @@options[class_name] ||= {}
      class_options.merge! build_options(locks, options)
    end

    #def self.bit_for(klass, lock)
    #  bit = @@hash[class_or_super(klass)][lock.to_s.downcase.to_sym]
    #  if bit.nil?
    #    raise LockError.new("Lock '#{lock}' is unknown to class '#{klass.name}'")
    #  else
    #    bit
    #  end
    #end

    def self.options_for(klass, lock)
      @@options ||= {}
      class_options = @@options[class_or_super(klass)] || {}
      class_options[lock.to_s.downcase.to_sym] || {}
    end

    def self.locks_for(klass, bits)
      hash = @@hash[class_or_super(klass)]

      # keep the order of the bits here
      locks = hash.inject([]) do |rev, (l,b)|
        rev[bits & b] = l
        rev
      end
      locks[1..-1].compact
    end

    def self.each_holder_with_locks(*args)
      if args[0].is_a? Hash
        locks_by_holders(args[0]).each do |holder, locks|
          yield holder, locks
        end
      else
        yield *args
      end
    end

    protected

    def self.reject_existing_locks!(class_hash, locks)
      if locks.is_a? Hash
        locks.reject!{|k,v| class_hash.keys.include? k}
      elsif locks.is_a? Enumerable
        locks.reject!{|k| class_hash.keys.include? k}
      end
    end

    def self.locks_by_holders(holders_by_lock)
      holders_by_lock.inject({}) do |locks_by_holders, (lock, holders)|
        holders = [holders] unless holders.is_a? Array
      holders.each do |holder|
        locks_by_holders[holder] ||= []
        locks_by_holders[holder].push lock
      end
      locks_by_holders
      end
    end

    def self.build_bit_hash(locks, offset)
      bitwise_hash = {}
      if locks.is_a? Hash
        locks.each do |lock, value|
          bitwise_hash[lock] = 2 ** value
        end
      elsif locks.is_a? Enumerable
        locks.each_with_index do |lock, index|
          bitwise_hash[lock] = 2 ** (index + offset)
        end
      end
      bitwise_hash
    rescue ArgumentError
      raise LockError.new("Lock bits must be integers or longs.")
    end

    def self.build_options(locks, options)
      symbols = locks.is_a?(Hash) ? locks.keys : locks
      symbols.inject({}) do |hash, sym|
        hash.merge(sym => options)
      end
    end

    def self.class_or_super(klass)
      current=klass
      until @@hash.keys.include?(current.name) do
        current = current.superclass
        if current.nil?
          raise LockError.new("Class #{klass} not registered with acts_as_locked.")
        end
      end
      current.name
    end

  end
end # CastleGates
