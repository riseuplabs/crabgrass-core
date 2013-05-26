class CrabgrassException < Exception
  attr_accessor :options
  attr_accessor :message
  def initialize(message = nil, opts={})
    self.options = opts
    self.message = message
    super(message)
  end

  def bold(str)
    "<b>#{h(str)}</b>".html_safe
  end

  def to_s
    [self.message].flatten.join("<br/>").html_safe
  end
end

# the user does not have permission to do that.
class PermissionDenied < CrabgrassException
  def initialize(message='', opts={})
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

# report a not found error and return 404
class ErrorNotFound < CrabgrassException
  def initialize(thing, options={})
    @thing = thing
    super("",options)
  end
  def to_s
    I18n.t(:thing_not_found, :thing => @thing).capitalize
  end
  def status
    :not_found
  end
end

# a list of errors with a title. oooh lala!
class ErrorMessages < ErrorMessage
  attr_accessor :title, :errors
  def initialize(title,*errors)
    self.title = title
    self.errors = errors
  end
  def to_s
    self.errors.join("\n")
  end
end

# extend base Exception class to have record() method.
# this is useful like so:
#
#  begin
#    @page = Page.create!( ... )
#  rescue Exception => exc
#    @page = exc.record
#    flash_message_now :exception => exc
#  end
#
#  This way, errors can be handled by the exception, and the field in the form
#  will get little red boxes because @page is set.
#  nifty.
#
class Exception
  def record
    nil
  end
end

