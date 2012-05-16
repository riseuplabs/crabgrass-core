#
# These modules are included in ActiveRecord objects that get registered as holders.
#

module CastleGates
module ActsAsHolder

  #def self.included(base)
  #  base.class_eval do
  #    def self.acts_as_holder()
  #      extend  CastleGates::ActsAsHolder::ClassMethods
  #      include CastleGates::ActsAsHolder::InstanceMethods
  #    end
  #  end
  #end

  module ClassMethods
    def self.extended(base)
      base.class_eval do
        class << self
          attr_accessor :holder_definition
        end
      end
    end
  end

  module InstanceMethods
    def holder_definition
      self.class.holder_definition
    end
    def holder_code_suffix
      self.id
    end
  end

end
end
