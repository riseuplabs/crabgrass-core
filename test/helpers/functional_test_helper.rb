module FunctionalTestHelper

  def assert_permission_denied(failure_message='missing "permission denied" message')
    if block_given?
      begin
        yield
      rescue PermissionDenied
        return true
      end
    end
    errors = flash_messages :warning
    assert message_text(errors).grep("Permission Denied")
  end

  def assert_login_required
    assert_response :redirect
    assert_redirected_to login_path(:redirect => @request.path)
  end

  # can pass either a regexp of the flash error string,
  # or the error symbol
  def assert_error_message(arg=nil)
    errors = flash_messages :error
    assert errors.present?, 'there should have been flash errors'
    if arg
      if arg.is_a?(Regexp)
        assert message_text(errors).grep(arg).present?, 'error message did not match %s. it was %s.'%[arg.inspect, message_text(errors).inspect]
      elsif arg.is_a?(Symbol) or arg.is_a?(String)
        assert message_text(errors).detect { |text| text == arg.t }, 'error message did not match %s. it was %s'%[arg.inspect, message_text(errors).inspect]
      end
    end
  end

  def assert_message(regexp=nil)
    assert flash_messages.present?, 'no flash messages'
    if regexp
      assert message_text(flash_messages).grep(regexp).present?, 'flash message did not match %s. it was %s.'%[regexp.inspect, message_text(flash_messages).inspect]
    end
  end

  def assert_success_message(title_regexp = nil, text_regexp = nil)
    assert_equal 'success', flash[:type]
    if title_regexp
      assert flash[:title] =~ title_regexp, 'success message title did not match %s. it was %s.'%[title_regexp.inspect, flash[:text]]
    end
    if text_regexp
      assert flash[:text] =~ text_regexp, 'success message text did not match %s. it was %s.'%[text_regexp, flash[:text]]
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

=begin
  # passing in a partial hash is deprecated in Rails 2.3. We need it though (at least for assert_login_required)
  def assert_redirected_to_with_partial_hash(options={ }, message=nil)
    clean_backtrace do
      assert_response(:redirect, message)
      return true if options == @response.redirected_to



      if @response.redirected_to.is_a?(Hash) && options.all? { |(key, value)|
            response_value = @response.redirected_to[key].to_s.dup
            test_value = value.to_s
            # remove leading / when redirected_to :controller
            response_value.gsub!(/^\//, "") if key.to_sym == :controller
            test_value == response_value
          }
        return true
      elsif options.is_a?(String) || @response.redirected_to.is_a?(String)
        url = @response.redirected_to.kind_of?(Hash) ? url_for(@response.redirected_to.merge(:only_path => true)) : @response.redirected_to
        options_url = options.kind_of?(Hash) ? url_for(options.merge(:only_path => (url =~ /^http:/ ? false : true))) : options
        assert_equal options_url, url[0..(options_url.size - 1)], (message || "Excpected response to be redirected to a url beginning with <#{options_url}>, but was a redirect to <#{url}>")
        return true
      end
    end
    assert_redirected_to_without_partial_hash(options, message)
  end

  def self.included(base)
    base.class_eval do
      class << self
        def determine_default_controller_class_with_removing_for(name)
          name.sub! /TestFor.*$/, 'Test'
          determine_default_controller_class_without_removing_for name
        end
        alias_method_chain :determine_default_controller_class, :removing_for
      end
    end

    base.instance_eval do
      alias_method_chain :assert_redirected_to, :partial_hash if respond_to?(:assert_redirected_to)
    end
  end
=end

  private

  def flash_messages(type=nil)
    messages = flash[:messages] || flash[:hidden_messages]
    if type && messages
      messages.select{|message| message[:type] == type}
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
    texts
  end
end
