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

require 'singleton'
require 'rubygems'
require 'active_support'

#
# SilentNil
#
# A class that behaves like nil, but will not complain if you call methods on it.
# It just always returns more nil. Used by Object#try().
#

class SilentNil
  include Singleton

  delegate :to_s, :inspect, :nil?, :empty?, :zero?, :blank?, to: :nil
  delegate :|, :&, :^, :=~, :===, :==, :<=>, :"!", to: :nil

  def method_missing(*args)
    nil
  end

  protected
  def nil
    nil
  end

end

class NilClass
  def try(*args)
    if args.empty?
      SilentNil.instance
    else
      nil
    end
  end
end

class Object
  def try(*args, &block)
    if args.empty?
      block_given? ? yield(self) : self
    else
      public_send(*args, &block) if respond_to? args.first
    end
  end
end

