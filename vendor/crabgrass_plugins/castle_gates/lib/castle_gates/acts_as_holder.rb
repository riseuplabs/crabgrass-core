#
# This module is included in ActiveRecord objects that get registered as holders.
#

module CastleGates
  module ActsAsHolder
    module InstanceMethods
      def holder_code_suffix
        id
      end
    end
  end
end
