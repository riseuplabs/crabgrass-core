#
# Code that makes it easy to use activerecord associations as holders.
#
# We extend activerecord here, so it might break for later versions.
#

##
## AssociationProxyProxy
##

#
# This class is a proxy for AssociationProxy.
#
# This double proxy keeps us from accidently hitting the database
# and fetching the records from the association.
#
# For example, just the simple statement {@me.minions => :x} will trigger
# fetching all the minions. Instead, we use @me.associated(:minions)
# which will return an AssociationProxyProxy.
#
class AssociationProxyProxy
  def initialize(proxy)
    @proxy = proxy
  end
  def holder_definition
    @proxy.reflection.holder_definition
  end
  def holder_code_suffix
    @proxy.proxy_owner.id
  end
end

##
## Extend AssociationProxy
##

#
# make the private reflection variable accessible to the
# AssociationProxyProxy.
#
ActiveRecord::Associations::AssociationProxy.class_eval do
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
  # This reflection is available from the AssociationProxy
  # and will have a pointer to the holder definition.
  #
  class << self
    alias_method :associated, :reflect_on_association
  end

  #
  # return an association proxy proxy. double proxy!
  #
  def associated(symbol)
    AssociationProxyProxy.new(self.send(symbol));
  end
end
