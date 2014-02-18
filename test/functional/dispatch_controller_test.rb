require_relative '../test_helper'

class DispatchControllerTest < ActionController::TestCase

  def test_non_existent_context
    assert_raises ErrorNotFound do
      get :dispatch, _context: 'pretty-sure-this-context-does-not-exist'
    end
    assert_nil assigns[:user]
    assert_nil assigns[:group]
    assert_response 404
  end

end
