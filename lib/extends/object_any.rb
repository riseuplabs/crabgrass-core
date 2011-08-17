##
## ANY: extra support for any?() and adds any()
##

class NilClass
  def any?
    false
  end

  def any
    false
  end

  # nil.to_s => ""
  def empty?
    true
  end

end

class Symbol
  # should do the same as sym.to_s.any?. symbols are never empty, hence #=> true
  def any?
    true
  end
end

class TrueClass
  def any?
    true
  end
end

class FalseClass
  def any?
    false
  end
end

class Object

  def any?
    true
  end

  # just like any?() but instead of true returns the actual string.
  # useful like:
  #  str = str_a.any or atr_b.any
  def any
    any? ? self : nil
  end

  #def cast!(class_constant)
  #  raise TypeError.new unless self.is_a? class_constant
  #  self
  #end

  def respond_to_any? *args
    args.each do |arg|
      return true if self.respond_to? arg
    end
    false
  end

end


