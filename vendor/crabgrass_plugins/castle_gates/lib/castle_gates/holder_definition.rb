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
  attr_reader :abstract       # if true, there are no records associated with this holder definition.

  attr_reader :info           # i18n symbol for descriptive text
  attr_reader :label          # i18n symbol for short label

  attr_reader :model            # active record class, if any
  attr_reader :association_name # name of association, like 'friends' if model has_many :friends
  attr_reader :associated      # other holders for the same model

  def initialize(name, options)
    @name     = name.to_sym
    @prefix   = options[:prefix].to_s
    @abstract = options[:abstract]
    @info     = options[:info]
    @label    = options[:label] || @name
    @model    = options[:model]
    @association_name = options[:association_name]
    @associated = []

    #
    # add association links (used for resolving default bitfield values)
    #
    if association_name
      # if this is an association model, add to previously defined non-association defs.
      Holder.holder_defs.each do |name, hdef|
        if !hdef.association_name && hdef.model && (hdef.model.name == model.name)
          hdef.associated << self
        end
      end
    elsif model
      # if this is a regular model, add to previously defined association defs.
      Holder.holder_defs.each do |name, hdef|
        if hdef.association_name && (hdef.model.name == model.name)
          hdef.associated << self
        end
      end
    end
  end

  def get_holder_from_id(id)
    if association_name
      model.find(id).associated(association_name)
    elsif model
      model.find(id)
    elsif abstract
      name.to_sym
    end
  end

  def definition
    self
  end
end
end
