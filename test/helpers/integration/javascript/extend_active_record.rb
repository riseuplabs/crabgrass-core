# Transaction based fixtures and multi threated tests usually don't mix.
#
# This is a hacky workaround taken from
# https://github.com/jnicklas/capybara/blob/master/README.md#transactions-and-database-setup
#
# In theory it is only required for tests using poltergeist.
# But then again you either monkey patch AR or you don't.

class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
