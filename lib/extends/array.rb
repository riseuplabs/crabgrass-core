##
## ARRAY
##

class Array
  # creates an array suitable for options_for_select
  # ids are converted to strings, so the 'selected' argument should
  # be a string.
  def to_select(field, id = 'id')
    collect { |x| [x.send(field).to_s, x.send(id).to_s] }
  end

  # creates an array suitable for options_for_select.
  # for use with arrays of single values where you want the
  # option shown to be localized.
  # eg ['hi','bye'] --> [[I18n.t(:hi),'hi'],[I18n.t(:bye),'bye']]
  def to_localized_select
    collect { |a| [I18n.t(a.to_sym, default: a.to_s), a] }
  end

  def path
    join('/')
  end

  # an alias for self.compact.join(' ')
  def combine(delimiter = ' ')
    compact.join(delimiter)
  end

  # true if the intersection of the two arrays is not empty
  def any_in?(array)
    (self & array).any?
  end
end
