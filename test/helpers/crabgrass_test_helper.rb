### misc definition used by tests

class ParamHash < HashWithIndifferentAccess
end

module CrabgrassTestHelper

  def mailer_options
    {:site => Site.new(), :current_user => users(:blue), :host => 'localhost',
    :protocol => 'http://', :port => '3000', :page => @page}
  end

  # make sure the associations are at least defined properly
  def check_associations(m)
    @m = m.new
    m.reflect_on_all_associations.each do |assoc|
      assert_nothing_raised("association '#{assoc.name}' caused an error") do
        @m.send(assoc.name)
      end
    end
    true
  end

  # this is a handy method borrowed from shoulda
  unless defined?(assert_same_elements)
    def assert_same_elements(a1, a2, msg = nil)
      [:select, :inject, :size].each do |m|
        [a1, a2].each {|a| assert_respond_to(a, m, "Are you sure that #{a.inspect} is an array?  It doesn't respond to #{m}.") }
      end
      assert a1h = a1.inject({}) { |h,e| h[e] = a1.select { |i| i == e }.size; h }
      assert a2h = a2.inject({}) { |h,e| h[e] = a2.select { |i| i == e }.size; h }
      assert_equal(a1h, a2h, msg)
    end
  end

end
