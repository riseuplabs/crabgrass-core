require_relative '../test_helper'

class ContextsControllerTest < ActionController::TestCase

  def test_process_raises_not_found
    assert_raises ErrorNotFound do
      get :show, id: 'pretty-sure-this-context-does-not-exist'
    end
    assert_nil assigns[:user]
    assert_nil assigns[:group]
  end

end
