class CrabgrassException < StandardError
  attr_accessor :options
  attr_accessor :message
  def initialize(message = nil, opts = {})
    self.options = opts
    self.message = message
    super(message)
  end
end

# the user does not have permission to do that.
class PermissionDenied < CrabgrassException
  def initialize(message = '', opts = {})
    super(message, opts)
  end
end

# the user is not logged in and tried to access a restricted action.
class AuthenticationRequired < CrabgrassException; end

# thrown when an activerecord has made a bad association
# (for example, duplicate associations to the same object).
class AssociationError < CrabgrassException; end

# just report the error
class ErrorMessage < CrabgrassException; end

# ErrorNotFound is similar to ActiveRecord::RecordNotFound - but it allows
# specifying the type of thing that was not found for more detailed error
# messages.
#
# For the translations we use cascading translations. So say a group was not
# found... we will lookup the following:
# exception.title.group.not_found
# exception.title.not_found
# exception.not_found
# not_found
#
# For all of these %{thing} will be interpolated with a translation of :group.
# If there is no translation for the given class of things it will be an empty
# string.
#
class ErrorNotFound < CrabgrassException
  def initialize(thing)
    super nil, thing: thing
  end
end

# a list of errors with a title. oooh lala!
class ErrorMessages < ErrorMessage
  attr_accessor :title, :errors
  def initialize(title, *errors)
    self.title = title
    self.errors = errors
  end

  def to_s
    errors.join("\n")
  end
end

# extend StandardError to have record() method.
# this is useful like so:
#
#  begin
#    @page = Page.create!( ... )
#  rescue exc
#    @page = exc.record
#    flash_message_now :exception => exc
#  end
#
#  This way, errors can be handled by the exception, and the field in the form
#  will get little red boxes because @page is set.
#  nifty.
#
class StandardError
  def record
    nil
  end
end
