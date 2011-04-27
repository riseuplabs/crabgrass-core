require 'activesupport'
require "#{File.dirname(__FILE__)}/acts_as_locked/key.rb"

module ActsAsLocked

  class LockError < StandardError; end;

  def self.included(base)
    base.class_eval do
      # This allows you to define access on the object that act as locked.
      # A locked object can have different locks for different actions.
      # Access is granted via keys that belong to a keyring.
      # Keys can open different locks (realized via a bitmap)

      def self.acts_as_locked(*locks)

        has_many :keys, :class_name => "ActsAsLocked::Key", :as => :locked do

          def open?(locks, reload=false)
            self.reload if reload
            open = self.inject(0) {|any, key| any | key.mask}
            closed = proxy_owner.class.bits_for_locks(locks) & ~open
            closed == 0
          end
        end

        # let's use AR magic to cache keyss from the controller like this...
        # @pages = Page.find... :include => {:owner => :current_user_keys}
        has_many :current_user_keys,
          :class_name => "ActsAsLocked::Key",
          :conditions => 'keyring_code IN (#{User.current.access_codes.join(", ")})',
          :as => :locked do
          def open?(locks)
            open = self.inject(0) {|any, key| any | key.mask}
            closed = proxy_owner.class.bits_for_locks(locks) & ~open
            closed == 0
          end
        end


        named_scope :access_by, lambda { |holder|
          { :joins => :keys,
            :group => 'locked_id, locked_type',
            :conditions => Key.access_conditions_for(holder) }
        }

        # please use in conjunction with access_by like this
        # Klass.access_by(holder).allows(lock)
        named_scope :allows, lambda { |lock|
          bit = self.bits_for_locks(lock)
          { :conditions => "(#{bit} & ~keys.mask) = 0" }
        }

        class_eval do

          def has_access!(lock, holder)
            if has_access?(lock, holder)
              return true
            else
              # TODO: make the error message flexible and meaningful
              raise LockDenied.new(I18n.t(:permission_denied))
            end
          end

          def has_access?(lock, holder = User.current)
            return true
            # ^^^ tmp hack until keys.yml is checked in.
            if holder == User.current
              # these might be cached through AR.
              current_user_keys.open?(lock)
            else
              # the named scope might have changed so we need to reload.
              keys.for_holder(holder).open?(lock, true)
            end
          end

          def grant!(*args)
            ActsAsLocked::Locks.get_holders_from_args(*args) do |holder, locks, options|
              code = Key.code_for_holder(holder)
              key = keys.find_or_initialize_by_keyring_code(code)
              key.open! locks, options || {}
            end
          end

          # no options so far
          def revoke!(*args)
            ActsAsLocked::Locks.get_holders_from_args(*args) do |holder, locks, options|
              code = Key.code_for_holder(holder)
              key = keys.find_or_initialize_by_keyring_code(code)
              key.revoke! locks
            end
          end

          def keys_by_lock
            keys.inject({}) do |hash, key|
              key.locks.each do |lock|
                hash[lock] ||= []
                hash[lock].push key
              end
              hash
            end
          end



          protected


          def self.bits_for_locks(locks)
            return ~0 if locks == :all
            locks = [locks] unless locks.is_a? Array
            locks.inject(0) {|any, lock| any | self.bit_for(lock)}
          end

          def self.locks_for_bits(bits)
            ActsAsLocked::Locks.locks_for(self, bits)
          end

          def self.bit_for(lock)
            ActsAsLocked::Locks.bit_for(self, lock)
          end

          def self.add_locks(*locks)
            locks = locks.first if locks.first.is_a? Enumerable
            ActsAsLocked::Locks.add_bits(self.name, locks)
          end
        end
        if locks.any?
          self.add_locks(*locks)
        end
      end

    end
  end

  module Locks

    def self.add_bits(class_name, locks)
      @@hash ||= {}
      class_hash = @@hash[class_name] ||= {}
      if locks.is_a? Hash
        locks.reject!{|k,v| class_hash.keys.include? k}
      elsif locks.is_a? Enumerable
        locks.reject!{|k| class_hash.keys.include? k}
      end
      class_hash.merge! build_bit_hash(locks, @@hash[class_name].count)
    end

    def self.bit_for(klass, lock)
      bit = @@hash[lock_for_class(klass)][lock.to_s.downcase.to_sym]
      if bit.nil?
        raise ActsAsLocked::LockError.new("Lock '#{lock}' is unknown to class '#{klass.name}'")
      else
        bit
      end
    end

    def self.locks_for(klass, bits)
      hash = @@hash[lock_for_class(klass)]
      array = hash.map{|l,b| l if (bits & b) != 0}
      array.compact
    end

    def self.get_holders_from_args(*args)
      if args[0].is_a? Hash
        args[0].each_pair do |lock, holders|
          holders = [holders] unless holders.is_a? Array
          holders.each do |holder|
            yield holder, lock, args[1]
          end
        end
      else
        yield *args
      end
    end


    protected
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
      raise ActsAsLocked::LockError.new("Lock bits must be integers or longs.")
    end

    def self.lock_for_class(klass)
      current=klass
      until @@hash.keys.include?(current.name) do
        current = current.superclass
        if current.nil?
          raise ActsAsLocked::LockError.new("Class #{klass} not registered with acts_as_locked.")
        end
      end
      current.name
    end
  end
end
