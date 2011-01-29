
require File.dirname(__FILE__) + '/lib/acts_as_locked'

ActiveRecord::Base.class_eval { include ActsAsLocked }

