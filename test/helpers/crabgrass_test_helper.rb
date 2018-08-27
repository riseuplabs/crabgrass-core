### misc definition used by tests

class ParamHash < HashWithIndifferentAccess
end

module CrabgrassTestHelper
  def mailer_options
    { site: Site.new, current_user: users(:blue), host: 'localhost',
      protocol: 'http://', port: '3000', page: @page }
  end

  # make sure the associations are at least defined properly
  def check_associations(m)
    @m = m.new
    m.reflect_on_all_associations.each do |assoc|
      assert_nothing_raised do
        @m.send(assoc.name)
      end
    end
    true
  end
end
