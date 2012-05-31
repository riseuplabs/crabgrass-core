
require File.dirname(__FILE__) + '/castle/associations'
require File.dirname(__FILE__) + '/castle/class_methods'
require File.dirname(__FILE__) + '/castle/instance_methods'

module CastleGates
  module ActsAsCastle
    def self.included(base)
      base.class_eval do
        def self.acts_as_castle(*gate_definitions)
          include CastleGates::Castle::Associations
          extend  CastleGates::Castle::ClassMethods
          include CastleGates::Castle::InstanceMethods

          if gate_definitions.any?
            self.add_locks(*gate_definitions)
          end
        end

        def self.acts_as_castle2(*gate_definitions)
          include CastleGates::Castle::Associations
          extend  CastleGates::Castle::ClassMethods
          include CastleGates::Castle::InstanceMethods

          if gate_definitions.any?
            gate_definitions.each do |gate_definition|
              self.add_gate(gate_definition)
            end
          end
        end
      end
    end
  end
end


