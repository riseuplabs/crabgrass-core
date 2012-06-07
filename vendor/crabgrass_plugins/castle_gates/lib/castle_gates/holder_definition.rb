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
  attr_reader :association_model # active record class of the other side of the association.
                                 # for example, for holder Group.associated(:users), User is the model,
                                 # 'users' is the association_name, and Group is the associated_model.
  attr_reader :associated       # an array of other holder definitions


  def initialize(name, options)
    @name     = name.to_sym
    @prefix   = options[:prefix].to_s
    @abstract = options[:abstract]
    @info     = options[:info]
    @label    = options[:label] || @name
    @model    = options[:model]
    @association_name = options[:association_name]
    @association_model = options[:association_model]
    @associated = []

    #
    # add association links (used for resolving default bitfield values)
    #
    if @association_model
      # if this is an association model, add to previously defined non-association defs.
      Holder.holder_defs.each do |name, hdef|
        if !hdef.association_model && (hdef.model == @model || hdef.model == @association_model)
          hdef.associated << self
        end
      end
    elsif @model
      # if this is a regular model, add to previously defined association defs.
      Holder.holder_defs.each do |name, hdef|
        if hdef.association_model && (hdef.model == @model || hdef.association_model == @model)
          hdef.associated << self
        end
      end
    end
  end

  def get_holder_from_id(id)
    if association_name
      association_model.find(id).associated(association_name)
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
