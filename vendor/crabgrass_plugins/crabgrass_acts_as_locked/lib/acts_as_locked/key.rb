module ActsAsLocked
  class Key < ActiveRecord::Base
    belongs_to :locked, :polymorphic => true

    named_scope :for_holder, lambda { |holder|
      { :conditions => access_conditions_for(holder) }
    }

    named_scope :for_public, :conditions => "keyring_code IS NULL"

    cattr_accessor :symbol_codes
    cattr_accessor :holder_klass
    cattr_accessor :holder_block

    # update! takes a hash with locks as keys.
    # all locks with true values can be opened
    # all locks with false values can not be opened
    # locks that are not specified are left untouched
    # returns an array of the locks set.
    def update!(locks_hash = {})
      # make sure we only have valid keys
      locks_hash.slice self.locked.class.locks_for_bits(~0)
      grants = locks_hash.map{|k,v|k if v == 'true'}.compact
      revokes = locks_hash.map{|k,v|k if v == 'false'}.compact
      self.open! grants
      self.revoke! revokes
      return grants + revokes
    end
    
    def open!(locks, options = {})
      if options[:reset]
        self.mask = bits_for_locks(locks)
      else
        self.mask |= bits_for_locks(locks)
      end
      save
    end

    def revoke!(locks)
      self.mask &= ~bits_for_locks(locks)
      save
    end


    def bits_for_locks(locks)
      self.locked.class.bits_for_locks(locks)
    end

    def locks(options={})
      klass = self.locked.class
      if options[:disabled]
        locks = klass.locks_for_bits(~self.mask)
      else
        locks = klass.locks_for_bits(self.mask)
      end
      postfix = klass.name.underscore
      if options[:with_class]
        locks.map{|l| (l.to_s + '_' + postfix).to_sym}
      elsif options[:select_options]
        locks.map{|l| [(l.to_s + '_' + postfix).to_sym, klass.bits_for_locks(l)]}
      else
        locks
      end
    end

    def holder
      ActsAsLocked::Key.holder_for(self.keyring_code)
    end

    def self.access_conditions_for(holder)
      if holder.is_a? Symbol and code = self.symbol_codes[holder]
        ["keys.keyring_code = ?", code]
      elsif holder.respond_to? :access_codes
        ["keys.keyring_code IN (?)", holder.access_codes]
      elsif holder.respond_to? :keyring_code
        ["keys.keyring_code = ?", holder.keyring_code]
      else
        "keys.keyring_code IS NULL"
      end
    end

    def self.holder_for(keyring_code)
      if self.holder_klass
        self.holder_klass.find(keyring_code)
      elsif !self.holder_block.nil?
        self.holder_block.call(keyring_code)
      end
    end

    # There are two ways of using this...
    # if all holders are of one class and the code is the id use
    #   resolve_holder Klass
    # otherwise you need to specify a decoding function
    #   resolve_holder do ...
    #
    def self.resolve_holder(klass = nil, &block)
      if block_given?
        self.holder_block = block
        self.holder_klass = nil
      elsif klass.is_a? Class
        self.holder_klass = klass
      elsif klass.is_a? Symbol or klass.is_a? String
        self.holder_klass = klass.to_s.capitalize.constantize
      end
    end


    def self.symbol_for(code)
      symbol_codes.detect{|k,v| v == code}.first
    end

    def self.code_for_holder(holder)
      holder = holder.to_sym if holder.is_a? String
      if holder.is_a? Symbol
        symbol_codes[holder] or
        raise ActsAsLocked::LockError.new("ActsAsLocked: Entity alias '#{holder}' is unknown.")
      else
        holder.keyring_code
      end
    end
  end
end
