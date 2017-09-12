class NilClass
  # nil.to_s => ""
  def empty?
    true
  end

  # nil.to_i => 0
  def zero?
    true
  end

  def first
    nil
  end

  def each
    nil
  end

  def to_sym
    self
  end
end
