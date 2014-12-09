module CachingTestHelper

  def assert_increases(object, method)
    old = object.public_send method
    yield
    new = object.reload.public_send method
    assert old < new,
      "#{method} should have increased for #{object.class.name}."
  end

  def assert_preserves(object, method)
    old = object.public_send method
    yield
    new = object.reload.public_send method
    assert_equal old, new,
      "#{method} should have been preserved for #{object.class.name}."
  end
end
