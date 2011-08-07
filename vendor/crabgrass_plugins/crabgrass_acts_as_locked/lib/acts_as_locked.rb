require 'active_support'
require "#{File.dirname(__FILE__)}/acts_as_locked/key.rb"

module ActsAsLocked

  class LockError < StandardError; end;

  def self.included(base)

    base.class_eval do

      #
      # This allows you to define access on the object that act as locked.
      # A locked object can have different locks for different actions.
      # Access is granted via keys that belong to a keyring.
      # Keys can open different locks (realized via a bitmap)
      #
      def self.acts_as_locked(*locks_to_define)

        has_many :keys, :class_name => "ActsAsLocked::Key", :as => :locked do

          def open?(locks, reload=false)
            self.reload if reload
            proxy_owner.class.keys_open_locks?(self, locks)
          end

          def find_or_initialize_by_holder(holder)
            code = Key.code_for_holder(holder)
            self.find_or_initialize_by_keyring_code(code)
          end

          #
          # filter the list of keys, including certain holders and
          # excluding others. this happens in-memory, and does not change the db.
          #
          # options is a hash with keys :include and/or :exclude and/or :order
          # , which consist of arrays of holder objects.
          #
          # we preserve the order of the includes.
          #
          def filter_by_holder(options)
            inc = options[:include]
            exc = options[:exclude]
            ord = options[:order] || inc
            keys = self.all
            sorted = []
            ord.each do |holder|
              if key = keys.detect {|key| key.holder?(holder)}
                sorted << key
                keys.delete key
              elsif inc.include? holder
                sorted << Key.new(:locked => proxy_owner, :holder => holder)
              end
            end
            sorted.concat keys
            exc.each do |holder|
              sorted.delete_if {|key| key.holder?(holder)}
            end
            return sorted
          end
        end

        # let's use AR magic to cache keys from the controller like this...
        # @pages = Page.find... :include => {:owner => :current_user_keys}
        has_many :current_user_keys, :class_name => "ActsAsLocked::Key", :conditions => 'keyring_code IN (#{User.current.access_codes.join(", ")})', :as => :locked do

          def open?(locks)
            proxy_owner.class.keys_open_locks?(self, locks)
          end
        end

        named_scope :access_by, lambda { |holder|
          { :joins => :keys,
            :select => "DISTINCT #{self.table_name}.*",
            :conditions => Key.access_conditions_for(holder) }
        }

        # please use in conjunction with access_by like this
        # Klass.access_by(holder).allows(lock)
        named_scope :allows, lambda { |lock|
          { :conditions => self.conditions_for_locks(lock) }
        }

        def has_access!(lock, holder)
          if has_access?(lock, holder)
            return true
          else
            #
            # For now, I am making acts_as_locked throw PermissionDenied
            # when permission is being denied.
            #
            # However, PermissionDenied is specific to crabgrass.
            #
            raise PermissionDenied.new
          end
        end

        def has_access?(lock, holder = User.current)
          holder = :public if holder.is_a? UnauthenticatedUser
          if holder == User.current
            # these might be cached through AR.
            current_user_keys.open?(lock)
          else
            # the named scope might have changed so we need to reload.
            keys.for_holder(holder).open?(lock, true)
          end
        end

        # for a single holder call
        # grant! user.friends, [:pester, :see]
        #
        # for multiple holders you can use a hash instead:
        # grant! :see => :public, :pester => [user.friends, user.peers]
        #
        # Options:
        # :reset => remove all other locks granted to the holders specified
        #           (defaults to false)
        def grant!(*args)
          options = args.pop if args.count > 1 and args.last.is_a? Hash
          ActsAsLocked::Locks.each_holder_with_locks(*args) do |holder, locks|
            key = keys.find_or_initialize_by_holder(holder)
            key.grant! locks, options
            key
          end
        end

        # no options so far
        def revoke!(*args)
          ActsAsLocked::Locks.each_holder_with_locks(*args) do |holder, locks|
            key = keys.find_or_initialize_by_holder(holder)
            key.revoke! locks
            key
          end
        end

        # this appears to be only used for testing.
        def keys_by_lock
          keys.inject({}) do |hash, key|
            key.locks.each do |lock|
              hash[lock] ||= []
              hash[lock].push key
            end
            hash
          end
        end

        def self.locks
          self.locks_for_bits ~0
        end

        protected

        def self.keys_open_locks?(keys, locks)
          open = bits_for_keys(keys)
          locked = bits_for_locks(locks)
          (locked & ~open) == 0
        end

        def self.bits_for_keys(keys)
          return keys.mask unless keys.respond_to? :inject
          keys.inject(0) {|any, key| any | key.mask}
        end

        def self.conditions_for_locks(locks)
          bit = self.bits_for_locks(locks)
          "(#{bit} & ~keys.mask) = 0"
        end

        def self.bits_for_locks(locks)
          return ~0 if locks == :all
          return self.bit_for(locks) unless locks.respond_to? :inject
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

        if locks_to_define.any?
          self.add_locks(*locks_to_define)
        end

      end
    end
  end

  module Locks

    def self.add_bits(class_name, locks)
      @@hash ||= {}
      class_hash = @@hash[class_name] ||= {}
      reject_existing_locks!(class_hash, locks)
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
