
require File.dirname(__FILE__) + '/lib/acts_as_permissive'

ActiveRecord::Base.class_eval { include ActsAsPermissive }

