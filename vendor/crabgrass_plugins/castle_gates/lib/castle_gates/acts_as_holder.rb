module CastleGates
module ActsAsHolder

  def self.included(base)
    base.class_eval do
      def self.acts_as_holder()

        ##
        ## CLASS ATTRIBUTES
        ##

        class << self
          attr_reader :holder
        end
        @holder = nil

        ##
        ## CLASS METHODS
        ##

        #
        # must be called manually on acts_as_holder classes
        # this creates the global holder definition.
        #
        def self.define_holder(id)
          name = self.name.downcase.to_sym
          @holder = Holder.define name, :id => id, :type => self
        end

        ##
        ## INSTANCE METHODS
        ##

        #def holder_code
        #  Holder.code(self)
        #end

        #def key_holders
        #  # can be overridden by classes in order to specify a list of related holders
        #end

        def holder
          self.class.holder
        end

      end # acts_as_holder
    end
  end

end
end
