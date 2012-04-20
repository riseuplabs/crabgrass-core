#
# Castle Associations
#

module CastleGates
module Castle
module Associations

def self.included(base)
  base.class_eval do

    ##
    ## KEYS
    ##

    has_many :keys, :class_name => "CastleGates::Key", :as => :castle do

      def open?(locks, reload=false)
        self.reload if reload
        proxy_owner.class.keys_open_locks?(self, locks)
      end

      #
      # gate_bitfield is a property of a single key.
      # but! maybe we want to know the sum total bitfield of a series of keys.
      # 
      def gate_bitfield
        if ActiveRecord::Base.connection.adapter_name == 'SQLite'
          self.inject(0) {|prior, key| prior | key.gate_bitfield}
        else
          self.calculate(:bit_or, :gate_bitfield)
        end
      end

      #def find_or_initialize_by_holder(holder)
      #  self.find_or_initialize_by_holder_code(holder.code)
      #end

      #def find_or_create_by_holder(holder)
      #  self.find_or_create_by_holder_code(holder.code)
      #end

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

    end # has_many :keys

    ##
    ## CURRENT USER KEYS
    ##

    #
    # This uses ActiveRecord magic to allow you to pre-load the keys for current_user:
    #
    #   @pages = Page.find... :include => {:owner => :current_user_keys}
    #
    has_many :current_user_keys,
             :class_name => "CastleGates::Key",
             :conditions => 'holder_code IN (#{User.current.access_codes.join(", ")})',
             :as => :castle do
      
      def open?(locks)
        proxy_owner.class.keys_open_locks?(self, locks)
      end

      def gate_bitfield
        if ActiveRecord::Base.connection.adapter_name == 'SQLite'
          self.inject(0) {|prior, key| prior | key.gate_bitfield}
        else
          self.calculate(:bit_or, :gate_bitfield)
        end
      end

    end

    ##
    ## FINDERS
    ##

    # with_gates(gates).open_to(holders)

    #
    # returns all the castles accessible by the holders
    #
    named_scope :access_by, lambda { |holder|
      { :joins => :keys,
        :select => "DISTINCT #{self.table_name}.*",
        :conditions => Key.access_conditions_for(holder) }
    }

    #
    # used in conjunction with please use in conjunction with access_by like this
    # Klass.access_by(holder).allows(lock)
    named_scope :allows, lambda { |lock|
      { :conditions => self.conditions_for_locks(lock) }
    }

  end
end

end
end
end
