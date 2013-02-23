require File.dirname(__FILE__) + '/../test_helper'

class Picture::GeometryTest < ActiveSupport::TestCase

  def test_minw_and_minh
    geo = Picture::Geometry.new("100-0-100-0")
    assert_equal nil,geo.gm_size_param_from([400, 800])
    assert_equal "100x^",geo.gm_size_param_from([40, 80])
    assert_equal "100x^",geo.gm_size_param_from([80, 400])
    assert_equal "x100^",geo.gm_size_param_from([400, 80])
  end

  def test_minw_and_maxh
    geo = Picture::Geometry.new("100-0-0-100")
    assert_equal "x100",geo.gm_size_param_from([800, 400])
    assert_equal "100x^",geo.gm_size_param_from([80, 40])
    assert_equal nil,geo.gm_size_param_from([800, 40])
    # impossible to fullfill... cropping needed
    assert_equal "100x^",geo.gm_size_param_from([40, 80])
    assert_equal "100x^",geo.gm_size_param_from([40, 800])
  end

  def test_maxw_and_minh
    geo = Picture::Geometry.new("0-100-100-0")
    assert_equal "100x",geo.gm_size_param_from([400, 800])
    assert_equal "x100^",geo.gm_size_param_from([40, 80])
    assert_equal nil,geo.gm_size_param_from([80, 400])
    # impossible to fullfill... cropping needed
    assert_equal "x100^",geo.gm_size_param_from([400, 80])
  end

  def test_maxw_and_maxh
    geo = Picture::Geometry.new("0-100-0-100")
    assert_equal nil,geo.gm_size_param_from([40, 80])
    assert_equal "100x",geo.gm_size_param_from([400, 80])
    assert_equal "x100",geo.gm_size_param_from([80, 400])
    # not sure this is what we want... just documenting status quo here:
    assert_equal "100x",geo.gm_size_param_from([400, 800])
    assert_equal "x100",geo.gm_size_param_from([800, 400])
  end
end
