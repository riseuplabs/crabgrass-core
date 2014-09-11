require 'zeus/rails'

class CustomPlan < Zeus::Rails
  def default_bundle_with_test_env
    ::Rails.env = 'test'
    ENV['RAILS_ENV'] = 'test'
    default_bundle
  end

  def test_console
    console
  end

  def test_db
    dbconsole
  end

  def test_rake
    rake
  end
end

Zeus.plan = CustomPlan.new
