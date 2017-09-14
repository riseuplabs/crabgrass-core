require 'test_helper'

# This test uses Rack::Test::Methods because the exceptions controller is usually
# triggered from the Crabgrass::PublicExceptions middleware.
# So it behaves a bit different from your usual ActiveController::TestCase:
# * it requires app to be defined
# * it expects a path instead of an action in request calls like 'get'
# * it allows handing an env hash to these calls

class ExceptionsControllerTest < ActiveSupport::TestCase
  include Rack::Test::Methods

  def app
    ExceptionsController.action(:show)
  end

  def test_404_translation_scope
    get '404', {}, not_found_env(:group)
    assert last_response.not_found?
    assert_translations :not_found, '', :group
  end

  def test_404_translation_fallback
    get '404', {}, not_found_env(:shoe)
    assert last_response.not_found?
    assert_translations :not_found
  end

  def test_404_translates_thing
    get '404', {}, not_found_env(:invite)
    assert last_response.not_found?
    assert_translations :not_found, I18n.t(:invite)
  end

  def assert_translations(exception, thing = '', scope = nil)
    assert_response_with_translation exception,
                                     thing: thing,
                                     scope: [:exception, :title, scope].compact
    assert_response_with_translation exception,
                                     thing: thing,
                                     scope: [:exception, :description, scope].compact
  end

  def assert_response_with_translation(*args)
    assert_includes body_text, I18n.t(*args)
  end

  def body_text
    last_response.body.gsub(/(\n|<[^>]*>)+/, "\n")
  end

  def not_found_env(thing)
    { 'action_dispatch.exception' => ErrorNotFound.new(thing) }
  end
end
