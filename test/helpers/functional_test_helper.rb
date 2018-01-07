module FunctionalTestHelper
  def assert_permission_denied
    if block_given?
      begin
        yield
      rescue PermissionDenied, Pundit::NotAuthorizedError
        return true
      end
    end
    errors = flash_messages :warning
    assert_includes message_text(errors), 'Permission Denied'
  end

  def assert_login_required(&block)
    assert_raises AuthenticationRequired, &block
  end

  NOT_FOUND_ERRORS = [
    ActiveRecord::RecordNotFound,
    ErrorNotFound
  ].freeze

  def assert_not_found
    if block_given?
      assert_raises(*NOT_FOUND_ERRORS) do
        yield
      end
    else
      assert_response :not_found
    end
  end

  # can pass either a regexp of the flash error string,
  # or the error symbol
  def assert_error_message(arg = nil)
    errors = flash_messages :error
    assert errors.present?, 'there should have been flash errors'
    if arg
      if arg.is_a?(Regexp)
        assert_match arg, message_text(errors)
      elsif arg.is_a?(Symbol) or arg.is_a?(String)
        assert_includes message_text(errors), arg.t
      end
    end
  end

  def assert_message(regexp = nil)
    assert flash_messages.present?, 'no flash messages'
    if regexp
      assert_match regexp, message_text(flash_messages)
    end
  end

  def assert_layout(layout)
    assert_equal layout, @response.layout
  end

  # using mocks to test permissions
  # see MockableTestHelper for implementation of
  # expect and verify
  def assert_permission(permission, ret = true)
    @controller.expect_or_raise permission, ret
    yield
    begin
      @controller.verify
    rescue MockExpectationError => e
      message = "Asserted Permission was not called.\n"
      message += "  Params used were: #{@controller.params.inspect}.\n"
      action = @controller.params[:action]
      message += "  action was: #{action}.\n"
      method = @controller.class.permission_for_action(action)
      message += method ? "  Method selected would be: #{method}.\n" :
       "  No method was cached. Are you using login_required?\n"
      raise MockExpectationError.new(message)
    end
  end

  ##
  ## ROUTE HELPERS
  ##

  def url_for(options)
    @controller.url_for(options)
  end

  private

  def flash_messages(type = nil)
    messages = flash[:messages] || flash[:hidden_messages]
    if type && messages
      messages.select { |message| message[:type] == type }
    else
      messages
    end
  end

  def message_text(messages)
    return '' if messages.nil?
    texts = []
    messages.each do |message|
      # assumes message[:text] and message[:list] are both arrays
      if message[:text].is_a?(Array)
        texts += message[:text]
      elsif message[:text]
        texts << message[:text]
      end
      texts += message[:list] if message[:list]
    end
    texts.join
  end
end
