#
# Castle Associations
#

module CastleGates
module Castle
module Associations

def self.included(base)
  base.class_eval do

    ##
    ## FINDERS
    ##

    named_scope(:with_access, lambda {|args|
      holder, gates = args.first
      key_condition, key_values = Key.conditions_for_holder(holder)
      gate_condition = conditions_for_gates(gates)
      {
        :joins => :keys,
        :select => "DISTINCT #{self.table_name}.*",
        :conditions => [gate_condition + " AND " + key_condition, key_values]
      }
    })

    ##
    ## KEYS
    ##

    has_many :keys, :class_name => "CastleGates::Key", :as => :castle do
      #
      # finds a key for a holder, initializing it in memory if it does not exist.
      #
      def find_by_holder(holder)
        code = Holder.code(holder)
        key = find_or_initialize_by_holder_code(code)
        if key.new_record?
          castle = proxy_owner
          key.gate_bitfield |= castle.gate_set.default_bits(holder)
        end
        key
      end
    end

    ##
    ## CURRENT USER KEYS
    ##

    #
    # This uses ActiveRecord magic to allow you to pre-load the keys for current_user:
    #
    #   @pages = Page.find... :include => {:owner => :current_user_keys}
    #
    # has_many :current_user_keys,
    #          :class_name => "CastleGates::Key",
    #          :conditions => 'holder_code IN (#{User.current.access_codes.join(", ")})',
    #          :as => :castle do
    #   def open?(locks)
    #     proxy_owner.class.keys_open_locks?(self, locks)
    #   end
    #   def gate_bitfield
    #     if ActiveRecord::Base.connection.adapter_name == 'SQLite'
    #       self.inject(0) {|prior, key| prior | key.gate_bitfield}
    #     else
    #       self.calculate(:bit_or, :gate_bitfield)
    #     end
    #   end
    # end
  end
end

end
end
end
