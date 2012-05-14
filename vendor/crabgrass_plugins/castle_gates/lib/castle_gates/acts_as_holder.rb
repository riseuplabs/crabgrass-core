#
# This should technically be called 'acts_as_holder_reference'
#
# Why?
#
#   holder => an instance of class Holder.
#
#   holder reference => an ActiveRecord or Symbol instance
#     that corresponds to a unique Holder instance.
#
# Only the internal code needs to know about Holder class.
#

module CastleGates
module ActsAsHolder

  def self.included(base)
    base.class_eval do
      def self.acts_as_holder()
        extend  CastleGates::ActsAsHolder::ClassMethods
        include CastleGates::ActsAsHolder::InstanceMethods
      end
    end
  end

  module ClassMethods
    def self.extended(base)
      base.class_eval do
        class << self
          attr_accessor :holder_definition
        end
      end
    end

    #
    # must be called manually on acts_as_holder classes
    # this creates the global holder definition.
    #
    #def define_holder(id)
    #  name = self.name.downcase.to_sym
    #  self.holder = Holder.define name, :id => id, :type => self
    #end
  end

  module InstanceMethods
    #def holder_code
    #  Holder.code(self)
    #end

    #def key_holders
    #  # can be overridden by classes in order to specify a list of related holders
    #end

    def holder_definition
      self.class.holder_definition
    end

    def holder_code_suffix
      self.id
    end

  end

end
end
