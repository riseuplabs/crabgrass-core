##
## Try
##

#
# Object#try() has been added to rails 2.3. It allows you to call a method on
# an object in safe way that will not bomb out if the object is nil.
#
# This try is similar, but also adds a way of calling try with zero args.
#
# Examples:
#
#  @person.try.name
#
#     this will call 'name' on person, unless it is nil.
#     similar to:
#
#       @person.name if @person
#
#  @person.try(:flags).try[:status]
#
#     In other words, calls to try can be chained.
#     This is similar to writing:
#
#       if @person and @person.respond_to?(:flags) and !@person.flags.nil?
#         @person.flags[:status]
#       end
#

require 'rubygems'
require 'active_support'

class NilClass
  def try(*args)
    nil
  end
end

class Object
  def try(method=nil, *args, &block)
    method.nil? ? self : __send__(method, *args, &block)
  end
end

