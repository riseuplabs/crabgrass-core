require 'rubygems'
RAILS_GEM_VERSION = '~> 2.3.11'
require 'minitest/autorun'
require 'mocha'
gem 'activesupport', RAILS_GEM_VERSION
require 'active_support'
require 'active_support/test_case'
gem 'activerecord', RAILS_GEM_VERSION
require 'active_record'

# for guard
gem 'guard'
gem 'rb-inotify'
gem 'libnotify'

RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + "/../../../")

module Rails
  module VERSION
    MAJOR = 2
    MINOR = 3
    STRING = "2.3.11"
  end
end

class ActiveSupport::TestCase
  def self.use_transactional_fixtures=(value)
  end
end

require 'unit_record'
ActiveRecord::Base.disconnect! :stub_associations => true, :strategy => :noop
ActiveRecord::Base.logger = Logger.new(STDOUT)

class Discussion < ActiveRecord::Base
end

class User < ActiveRecord::Base
end

require File.expand_path(RAILS_ROOT + "/lib/extends/active_record.rb")
require File.expand_path(RAILS_ROOT + "/app/models/associations/relationship.rb")
require File.expand_path(RAILS_ROOT + "/app/models/observers/relationship_observer.rb")
require File.expand_path(RAILS_ROOT + "/app/models/activity/activity.rb")
require File.expand_path(RAILS_ROOT + "/app/models/activity/friend_activity.rb")

ActiveRecord::Base.observers = :relationship_observer
ActiveRecord::Base.instantiate_observers

