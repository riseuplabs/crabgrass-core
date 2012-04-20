require 'active_support'
require File.dirname(__FILE__) + '/lib/castle_gates'

ActiveRecord::Base.class_eval { include CastleGates::ActsAsCastle }
ActiveRecord::Base.class_eval { include CastleGates::ActsAsHolder }