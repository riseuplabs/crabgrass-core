require 'test_helper'

class ApplicationControllerTest < ActiveSupport::TestCase

  test "can set stylesheet" do
    class SimpleController < ApplicationController; end
    SimpleController.stylesheet :test
    assert_equal hash_for_all(:test), SimpleController.stylesheets
    assert_nil ApplicationController.stylesheets
  end

  test "can set javascript" do
    class SimpleController < ApplicationController; end
    SimpleController.javascript :test
    assert_equal hash_for_all(:test), SimpleController.javascripts
    assert_nil ApplicationController.javascripts
  end

  test "stylesheets do not mess with super class" do
    class BaseController < ApplicationController; end
    class SubController < BaseController; end
    BaseController.stylesheet :base
    SubController.stylesheet :sub
    assert_equal hash_for_all(:base, :sub), SubController.stylesheets
    assert_equal hash_for_all(:base), BaseController.stylesheets
  end

  test "subclasses do not add duplicates" do
    class BaseController < ApplicationController; end
    class SubController < BaseController; end
    BaseController.stylesheet :base
    SubController.stylesheet :sub, :base
    assert_equal hash_for_all(:base, :sub), SubController.stylesheets
    assert_equal hash_for_all(:base), BaseController.stylesheets
  end

  def hash_for_all(*values)
    {all: values}
  end
end
