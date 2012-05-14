#
# Instances of class HolderDefinition define a type of holder.
#
# For example, if User is a holder, then there is a single HolderDefinition instance for
# the class User.
#
# Similarly, there is a single HolderDefinition instance for each symbolic holder, like :public.
#

module CastleGates
class HolderDefinition

  #
  # member attributes
  #
  attr_reader :name           # the symbol for this holder definition
  attr_reader :prefix         # the prefix for encoding holder codes
  attr_reader :type           # the class that corresponds to this holder definition, if any
  attr_reader :abstract       # if true, there are no records associated with this holder definition.

  def initialize(name, options)
    @name     = name
    @prefix   = options[:prefix]
    @type     = options[:type]
    @abstract = options[:abstract]
  end

end
end
