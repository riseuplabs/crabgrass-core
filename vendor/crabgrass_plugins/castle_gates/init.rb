require 'active_support'
require 'action_controller'
require File.dirname(__FILE__) + '/lib/castle_gates'

ActiveRecord::Base.class_eval {
  include CastleGates::ActsAsCastle
}

ActionController::Base.class_eval {
  protected
  def key_holders(*args)
    args.collect{|arg| CastleGates::Holder[arg]}
  end
}