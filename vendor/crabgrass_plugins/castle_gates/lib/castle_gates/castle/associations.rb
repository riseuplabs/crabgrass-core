#
# Castle Associations
#

module CastleGates
  module Castle
    module Associations
      extend ActiveSupport::Concern

      module ClassMethods
        ##
        ## FINDERS
        ##

        #
        # search for castle's with particular access.
        #
        # e.g. Fort.with_access(:public => :gate)
        #
        def with_access(args)
          holder, gates = args.first
          holder = Holder[holder, self]

          joins(:keys)
            .where(conditions_for_gates(gates))
            .where('castle_gates_keys.holder_code' => holder.all_codes)
            .distinct
        end

        #
        # alternative implementation of with_access using a subselect.
        # It's faster for getting all castles. However usually there are
        # conditions on the castles that make the join a lot faster.
        #
        def all_with_access(args)
          holder, gates = args.first
          subselect = subselect_for_holder_and_gates(holder, gates)
          where("#{quoted_table_name}.id IN (#{subselect})")
        end
      end
      included do
        ##
        ## KEYS
        ##

        has_many :keys,
                 class_name: 'CastleGates::Key',
                 as: :castle,
                 dependent: :delete_all do

          #
          # finds a key for a holder, initializing it in memory if it does not exist.
          #
          def find_by_holder(holder)
            holder = Holder[holder, self]
            code = holder.code
            # let's use preloaded keys if possible
            if loaded?
              key = detect { |k| k.holder_code == code }
              return key if key
            end
            where(holder_code: code).first_or_initialize
          end

          def select_holder_codes
            castle = proxy_association.owner
            sti_type = castle.store_full_sti_class ? castle.class.name : castle.class.base_class.name
            connection.select_values(format("SELECT DISTINCT `castle_gates_keys`.`holder_code` FROM `castle_gates_keys` WHERE `castle_gates_keys`.`castle_type` = '%s' AND `castle_gates_keys`.`castle_id` = %s", sti_type, castle.id))
          end
        end
      end
    end
  end
end
