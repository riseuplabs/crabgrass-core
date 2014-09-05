#
# Code that makes it easy to build holders based on Active Record associations
# and relations.
#
# For example Association.new(user, :peers) refers to all the
# peers of the given user.
#

##
## Association
##

#
# This class is a proxy for the AR relation
#
# This double proxy keeps us from accidently hitting the database
# and fetching the records from the relation.
#
# For example, just the simple statement {@me.minions => :x} will trigger
# fetching all the minions. Instead, we use @me.associated(:minions)
# which will return an Association.
#
class Association
  attr_reader :owner, :relationship

  # owner can be a class to refer to all associations of a certain type
  # for instance during definition or an instance to refer to a specific
  # association of a concrete record.
  def initialize(owner, relationship)
    @owner = owner
    @relationship = relationship
  end

  def holder_type
    "#{owner_class.name}-#{relationship}"
  end

  def holder_code_suffix
    @owner.id
  end

  def ==(other)
    if other.is_a? Association
      owner == other.owner &&
        relationship = other.relationship
    elsif other.is_a? Symbol
      false  # don't query the relation just to compare to Symbol
    else
      owner.send(:relationship) == other
    end
  end

  def owner_class
    owner.is_a?(Class) ? owner : owner.class
  end
end

##
## Extend CollectionProxy
##

#
# make the private reflection variable accessible to the
# Association.
#
ActiveRecord::Associations::CollectionProxy.class_eval do
  def reflection
    @reflection
  end
end

##
## Extend ActiveRecord::Base
##

ActiveRecord::Base.class_eval do
  #
  # returns an ActiveRecord::Reflection::AssociationReflection
  #
  # This reflection is available from the CollectionProxy
  # and will have a pointer to the holder definition.
  #
  class << self
    def associated(symbol)
      Association.new(self, symbol)
    end
  end

  #
  # return an association proxy proxy. double proxy!
  #
  def associated(symbol)
    Association.new(self, symbol)
  end
end
